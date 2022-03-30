#!/bin/tcsh

#=============================================
set list_nn = ( 01 02 05 07 08 \
				11 12 13 14 15 \
				18 19 20 21 23 \
				26 27 28 29 30 \
				31 32 33 34 35 \
				36 37 38 42 44 )
set list_nn = ( 01 )
set list_run = (`seq -f "r%02g" 1 6`)
#=============================================
set res = 2.683
set fwhm = 4
set thresh_motion = 0.4
#=============================================
set dir_root = $HOME/GA
set dir_hdd = /mnt/sda2/GA/fmri_data
set dir_raw = $dir_hdd/raw_data
set dir_afni = /usr/local/afni
#=============================================
## GA01: dist_PA, dist_AP 만 존재하지 않음.
set list_dir = ('rest' 'rest_SBREF' 'dist_PA' 'dist_AP')
foreach nn ($list_nn)
	foreach gg ('GA' 'GB')
		set subj = $gg$nn
		foreach dir ($list_dir)
			set obj = $dir_raw/$subj/$dir
			if ( ! -d $obj ) then
				echo $obj
			endif
		end
		foreach run ($list_run)
			set obj = $dir_raw/$subj/$run
			if ( ! -d $obj ) then
				echo $obj
			endif
			set obj = $dir_raw/$subj/${run}_SBREF
			if ( ! -d $obj ) then
				echo $obj
			endif
		end
	end
end
#=============================================
foreach gg ('GB')
	foreach nn ($list_nn)
		set subj = $gg$nn
		set dir_output = $dir_root/$nn/$gg
		if ( ! -d $dir_output ) then
			mkdir -p -m 755 $dir_output
		endif

		## ==================================================================
		## Convert *.IMA files to *.BRIK/*.HEAD
		### B0 distortion
		foreach B0 ('dist_PA' 'dist_AP')
			set dir = $dir_raw/$subj/$B0
			if ( -d $dir ) then
				cd $dir_output
				Dimon -infile_pat "$dir/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
				-gert_outdir $dir_output -gert_quit_on_err
				3dWarp -deoblique -prefix $dir_output/$B0.$subj.nii $dir_output/temp+orig
				rm $dir_output/temp*
			endif
		end
		### main task
		foreach run ($list_run)
			cd $dir_output
			Dimon -infile_pat "$dir_raw/$subj/$run/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
			-gert_outdir $dir_output -gert_quit_on_err
			3dWarp -deoblique -prefix $dir_output/func.$run.$subj.nii $dir_output/temp+orig
			rm $dir_output/temp*
			
			cd $dir_output
			Dimon -infile_pat "$dir_raw/$subj/${run}_SBREF/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
			-gert_outdir $dir_output -gert_quit_on_err
			3dWarp -deoblique -prefix $dir_output/SBREF.$run.$subj.nii $dir_output/temp+orig
			rm $dir_output/temp*
		end
		### T1
		cd $dir_output
		Dimon -infile_pat "$dir_raw/$subj/MPRAGE/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
		-gert_outdir $dir_output -gert_quit_on_err
		3dWarp -deoblique -prefix $dir_output/MPRAGE.$subj.nii $dir_output/temp+orig
		rm $dir_output/temp*

		# ==================================================================
		########
		# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
		########
		set dir_data = $dir_root/$nn/$gg
		set dir_output = $dir_root/preprocessed/$nn/$gg
		if ( ! -d $dir_output ) then
			mkdir -p -m 755 $dir_output
		endif

		cd $dir_output
		## Will copy only the dataset with the given view (orig, acpc, tlrc).
		# ================================= skull-striping =================================
		3dSkullStrip -input $dir_data/MPRAGE.$subj.nii -prefix $subj.anat.ss.nii -orig_vol
		# ================================= unifize =================================
		## this program can be a useful step to take BEFORE 3dSkullStrip, since the latter program can fail if the input volume is strongly shaded -- 3dUnifize will (mostly) remove such shading artifacts.
		3dUnifize -input $subj.anat.ss.nii -prefix $subj.anat.unifize.nii -GM -clfrac 0.5
		# ================================= tlrc =================================
		## warp anatomy to standard space, input dataset must be in the current directory:
		@auto_tlrc -base $dir_afni/abin/MNI152_T1_2009c+tlrc -input $subj.anat.unifize.nii \
					-prefix anat_final.$subj.nii -no_ss -init_xform AUTO_CENTER

		# store forward transformation matrix in a text file
		cat_matvec anat_final.$subj+tlrc::WARP_DATA -I > warp.anat.Xat.1D
		# ==================================================================
		########
		# Func # : Despiking (3dDespike) -> Slice Timing Correction (3dTshift) -> Motion Correct EPI (3dvolreg)
		########  -> Alignment (@auto_tlrc) -> Spatial Blurring -> Nuisance Regression -> Scaling
		set dir_data = $dir_root/$nn/$gg
		set dir_output = $dir_root/preprocessed/$nn/$gg
		if ( ! -d $dir_output ) then
			mkdir -p -m 755 $dir_output
		endif
		
		cd $dir_output
		## apply 3dTcat to copy input dsets to results dir, while removing the first 0 TRs
 #		foreach run ($list_run)
 #			3dTcat -prefix $dir_output/pb00.$subj.$run.tcat $preproc_dir/$subj/func.$subj.$run+orig'[0..$]'
 #		end
		## if you want to remove the first 2 TRs (TR indices 0 and 1), use [2..$] instead of [0..$]
		## 2..$ -> $는 just a variable which means the very end of that array. Only keeping volumes two to the very end 라는 뜻.
		
		## data check: compute outlier fraction for each volume
		## Calculate number of 'outliers' a 3D+time dataset, at each time point, and writes the results to stdout.
		## outliers -> MAD (Mean Absolute Deviation). If the MAD is 10, that means that at the RT we have an average of five median absolute deviations from the mean. Usually about 5.5 MAD is considered an outlier.
		touch out.pre_ss_warn.txt
		set npol = 4
		foreach run ($list_run)
			# ================================= outcount =================================
			## The formula that we use for polort, which is applied by afni_proc.py and by "3dDeconvolve -polort A", is pnum = 1 + floor(run_duration/150), where times are in seconds. Yes, pnum would be the order of polynomial used in 3dToutcount or 3dDeconvolve, while run_duration is the duration of the run in seconds (regardless of the number of time points).
			3dToutcount -automask -fraction -polort $npol -legendre $dir_data/func.$run.$subj.nii > outcount.$run.$subj.1D
			## polort = the polynomial order of the baseline model
			if ( `1deval -a outcount.$run.$subj.1D"{0}" -expr "step(a-0.4)"` ) then
				echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> out.pre_ss_warn.$subj.txt
			endif
		end
		## catenate outlier counts into a single time series
		cat outcount.r0?.$subj.1D > outcount.r_all.$subj.1D
		#================================ despike =================================
		## truncate spikes in each voxel's time series:
		foreach run ($list_run)
			3dDespike -NEW -nomask -prefix pb00.$run.despike.$subj.nii $dir_data/func.$run.$subj.nii
		end
		# ================================= tshift (pb01) =================================
		## slice timing alignment on volumes (default is -time 0)
		## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
		foreach run ($list_run)
			3dTshift -tzero 0 -quintic -prefix pb01.$run.tshift.$subj.nii pb00.$run.despike.$subj.nii
		end
		## quintic : 5th order of polynomial
		## tzero : to interpolate all the slices as though they were all acquired at the beginning of each TR.
		# ================================= blip: B0-distortion correction =================================
		## compute blip up/down non-linear distortion correction for EPI
 		foreach B0 ('dist_AP' 'dist_PA')
 				case 'dist_AP':
 					set bb = 'forward'
 					breaksw
 				case 'dist_PA':
 					set bb = 'reverse'
 					breaksw
 				default:
 					set bb = 'invalid'
 			endsw
 			## create median datasets from forward and reverse time series
 			3dTstat -median -prefix rm.blip.med.$bb.$subj.nii $dir_data/$B0.$subj.nii
 			
 			## automask the median datasets
 			3dAutomask -apply_prefix rm.blip.med.masked.$bb.$subj.nii rm.blip.med.$bb.$subj.nii
 		end	
		## compute the midpoint warp between the median datasets
		3dQwarp -plusminus -pmNAMES Rev For		\
			-pblur 0.05 0.05 -blur -1 -1		\
			-noweight -minpatch 9				\
			-source rm.blip.med.masked.reverse.$subj.nii	\
			-base rm.blip.med.masked.forward.$subj.nii	\
			-prefix blip_warp.$subj.nii
		
		## warp median datasets (forward and each masked) for QC checks
		3dNwarpApply -quintic -nwarp blip_warp.${subj}_For_WARP.nii \
			-source rm.blip.med.forward.$subj.nii \
			-prefix blip.med.forward.$subj.nii
		
		3dNwarpApply -quintic -nwarp blip_warp.${subj}_For_WARP.nii \
			-source rm.blip.med.masked.forward.$subj.nii \
			-prefix blip.med.masked.forward.$subj.nii
		
		3dNwarpApply -quintic -nwarp blip_warp.${subj}_Rev_WARP.nii \
			-source rm.blip.med.masked.reverse.$subj.nii \
			-prefix blip.med.masked.reverse.$subj.nii
		
		# warp EPI time series data
		foreach run ($list_run)
			3dNwarpApply -quintic -nwarp blip_warp.${subj}_For_WARP.nii \
				-source pb01.$run.tshift.$subj.nii \
				-prefix pb01.$run.blip.$subj.nii
		end
		# ================================== Align Anatomy with EPI ==================================
		cd $dir_output
		## 3dcopy tmp_epi and tmp_anat
		set tmp_anat = tmp.$subj.anat.unifize
		set tmp_epi = tmp.SBREF.r02.$subj
		3dcopy $subj.anat.unifize.nii $tmp_anat
		3dcopy $dir_data/SBREF.r02.$subj.nii $tmp_epi
		## align anatomical datasets to EPI registration base (default: anat2epi):
		align_epi_anat.py -anat2epi -anat $tmp_anat+orig -anat_has_skull no \
		    -epi $tmp_epi+orig -epi_base 0 \
		    -epi_strip 3dAutomask \
		    -suffix _al_junk \
			-check_flip \
		    -volreg off -tshift off -ginormous_move \
		    -cost lpa -align_centers yes
		## -cost nmi : weired result in the multiband8 protocol
		## -cost lpa (local pearson correlation)
		rm $dir_output/*.HEAD $dir_output/*.BRIK
		# ================================== register and warp (pb02) ========================
		cd $dir_output
		# register and warp
		foreach run ( $runs )
		    # apply catenated xform: blip/volreg/epi2anat/tlrc
		    3dNwarpApply -master MPRAGE.GB01_ns+tlrc -dxyz 2.5                    \
		                 -source pb01.$subj.r$run.tshift+orig                     \
		                 -nwarp "mat.r$run.warp.aff12.1D blip_warp_For_WARP+orig" \
		                 -prefix rm.epi.nomask.r$run
		
		    # warp the all-1 dataset for extents masking 
		    3dAllineate -base MPRAGE.GB01_ns+tlrc                                 \
		                -input rm.epi.all1+orig                                   \
		                -1Dmatrix_apply mat.r$run.warp.aff12.1D                   \
		                -mast_dxyz 2.5 -final NN -quiet                           \
		                -prefix rm.epi.1.r$run
		
		    # make an extents intersection mask of this run
		    3dTstat -min -prefix rm.epi.min.r$run rm.epi.1.r$run+tlrc
		end
		foreach run ($list_run)
			## register each volume to the base
			3dvolreg -verbose -zpad 1 -cubic -base $dir_data/SBREF.r02.$subj.nii \
				-1Dfile dfile.$run.$subj.1D -prefix rm.epi.$run.volreg.$subj.nii \
				-1Dmatrix_save mat.vr.aff12.$run.$subj.1D  \
				pb01.$run.blip.$subj.nii
		
			## create an all-1 dataset to mask the extents of the warp
			3dcalc -overwrite -a pb01.$run.blip.$subj.nii -expr 1 -prefix rm.epi.all1.$subj.nii
		
			## catenate volreg, epi2anat and tlrc transformations
			cat_matvec -ONELINE anat_final.$subj.nii::WARP_DATA -I \
				tmp.$subj.anat.unifize_al_junk_mat.aff12.1D -I \
				mat.vr.aff12.$run.$subj.1D > mat.warp.aff12.$run.$subj.1D
		
			## apply catenated xform : volreg, epi2anat and tlrc
			3dAllineate -base anat_final.$subj.nii \
				-input pb01.$run.blip.$subj.nii \
				-1Dmatrix_apply mat.warp.aff12.$run.$subj.1D \
				-mast_dxyz $res -prefix rm.epi.nomask.$run.$subj.nii
			## $res는 original data의 resolution과 맞춤
		
			## warp the all-1 dataset for extents masking
			3dAllineate -base $subj.anat.unifize+tlrc \
				-input rm.$subj.epi.all1+orig \
				-1Dmatrix_apply mat.$subj.$run.warp.aff12.1D \
				-final NN -quiet \
				-mast_dxyz $res  -prefix rm.epi.1.$subj.$run
		
			## make an extents intersection mask of this run
			3dTstat -min -prefix rm.epi.min.$subj.$run rm.epi.1.$subj.$run+tlrc    # -----NEED CHECK-----
		end
		
		## make a single file of registration params
		cat dfile.$subj.r0?.1D > dfile.$subj.r_all.1D
		
		## create the extents mask: mask_epi_extents+tlrc
		## (this is a mask of voxels that have valid data at every TR)
		## (only 1 run, so just use 3dcopy to keep naming straight)
		3dcopy rm.epi.min.$subj.rest+tlrc mask_epi_extents.$subj
		
		## and apply the extents mask to the EPI data
		## (delete any time series with missing data)
		foreach run ($list_run)
			3dcalc -a rm.epi.nomask.$subj.$run+tlrc -b mask_epi_extents.$subj+tlrc \
				-expr 'a*b' -prefix pb02.$subj.$run.volreg
		end
		# ================================================= blur (pb03) =================================================
		## blur each volume of each run
		foreach run ($list_run)
			3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.$run.blur \
				pb02.$subj.$run.volreg+tlrc
		end
		## For each run, blur each volume by a $fwhm mm FWHM (Full Width at Half Max) Gaussian kernel
		## $fwhm -> 4 is default, 6 is common
		
		# ================================================= mask =================================================
		## create 'full_mask' dataset (union mask)
		## create a 'brain' mask from the EPI data (dilate 1 voxel)
		
		foreach run ($list_run)
			3dAutomask -dilate 1 -prefix rm.mask_$run pb03.$subj.$run.blur+tlrc
		end
		## 3dAutomaks  :  Input dataset is EPI 3D+time, or a skull-stripped anatomical. Output dataset is a brain-only mask dataset.
		## -dilate nd  = Dilate the mask outwards 'nd' times.
		
		## create union of inputs, output type is byte
		3dmask_tool -inputs rm.mask_{*}+tlrc.HEAD -union -prefix full_mask.$subj
		## 3dmask_tool  -  for combining/dilating/eroding/filling mask
		
		## ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
		##      (resampled from tlrc anat). resample은 resolution을 맞춰 sampling을 다시 하는 것. resolution을 낮추면 down sampling하는 것.
		3dresample -master full_mask.$subj+tlrc -input $subj.anat.unifize+tlrc -prefix rm.resam.anat
		## convert to binary anat mask; fill gaps and holes
		3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj
		
		# ================================= scale (pb04) ==================================
		## scale each voxel time series to have a mean of 100 (be sure no negatives creep in)
		## (subject to a range of [0,200])
		foreach run ($list_run)
			3dTstat -prefix rm.mean_$run pb03.$subj.$run.blur+tlrc
			3dcalc -float -a pb03.$subj.$run.blur+tlrc -b rm.mean_$run+tlrc -c mask_epi_extents.$subj+tlrc \
				-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.$run.scale
		end
		# ================================ motion regressors =================================
		## 1d_tool.py will be used to create a censor file just before 3dDeconvolve
		
		## Example 7a. Output temporal derivative of motion regressors.  There are
		## 9 runs in dfile_rall.1D, and derivatives are applied per run.
		## 1d_tool.py -infile dfile_rall.1D -set_nruns 9 \
		## -derivative -write motion.deriv.1D
		
		## -demean : demean each run (new mean of each run = 0.0)
		## -derivative : take the temporal derivative of each vector (done as first backward difference)
		## compute de-meaned motion parameters (for use in regression)
		1d_tool.py -infile dfile.$subj.r_all.1D -set_nruns 1 -demean -write motion_demean.$subj.1D
		## compute motion parameter derivatives (just to have)
		1d_tool.py -infile dfile.$subj.r_all.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.1D
		## create censor file motion_${subj}_censor.1D, for censoring motion
		1d_tool.py -infile dfile.$subj.r_all.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}
		
		## subjA_enorm.1D is the euclidean norm of the derivative, before the extreme mask is applied.
		## -censor_prev_TR : for each censored TR, also censor previous
		
		foreach run ($list_run)
			1d_tool.py -infile dfile.$subj.$run.1D -set_nruns 1 -demean -write motion_demean.$subj.$run.1D
			1d_tool.py -infile dfile.$subj.$run.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.$run.1D
			1d_tool.py -infile dfile.$subj.$run.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}.$run
		end
		
		## compute motion magnitude time series: the Euclidean norm
		## (sqrt(sum squares)) of the motion parameter derivatives
		1d_tool.py -infile dfile.$subj.r_all.1D -set_nruns 1 \
			-derivative  -collapse_cols euclidean_norm \
			-write motion_{$subj}.eucl_norm.1D
		
		foreach run ($list_run)
			1d_tool.py -infile dfile.$subj.$run.1D -set_nruns 1 \
				-derivative  -collapse_cols euclidean_norm     \
				-write motion_{$subj}.$run.eucl_norm.1D
		end
		# ==================================================================
		echo "subject $subj completed!"
	end
end
