#!/bin/tcsh

#=============================================
set res = 2.683
set fwhm = 4
set thresh_motion = 0.4
#=============================================
set list_subj = (GP08 GP09 GP10 GP11 GP17 GP18 GP20 GP21)
set list_subj = (GP08)
set list_run = (r01 r02 r03)
#=============================================
set root_dir = $HOME/Desktop/GP
#=============================================
foreach subj ($list_subj)
	set tmp = $root_dir/$subj/day2
	set raw_dir = $tmp/`ls $tmp`
	set output_dir = $root_dir/preprocessed/$subj
	if ( ! -d $output_dir ) then
		mkdir -p -m 755 $output_dir
	endif
	#=============================================
	set T1 = $raw_dir/T1
	#=============================================
	## rename folders
	set dist_PA = $raw_dir/dist_PA
	set dist_AP = $raw_dir/dist_AP
	cd $raw_dir
	if ( ! -d $dist_PA ) then
		mv ./DISTORTION_CORR_64CH_INVERT_TO_PA_00?? $dist_PA
	endif
	if ( ! -d $dist_AP ) then
		mv ./DISTORTION_CORR_64CH_AP_00?? $dist_AP
	endif
	foreach nn (`seq -f '%01g' 1 3`)
		set tmp = $raw_dir/$list_run[$nn]
		if ( ! -d $tmp ) then
			mv ./RUN${nn}_MUITIBAND8_EPI_CMRR_00?? $tmp
		endif
		set tmp = $raw_dir/$list_run[$nn]_SBREF
		if ( ! -d $tmp ) then
			mv ./RUN${nn}_MUITIBAND8_EPI_CMRR_00?? $tmp
		endif
	end
	#=============================================
 #	## Convert *.IMA files to *.BRIK/*.HEAD
 #	cd $dist_PA
 #	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
 #	-gert_outdir $output_dir -gert_quit_on_err
 #	3dWarp -deoblique -prefix $output_dir/$subj.dist_PA $output_dir/temp+orig
 #	rm $output_dir/temp*
 #	
 #	cd $dist_AP
 #	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
 #	-gert_outdir $output_dir -gert_quit_on_err
 #	3dWarp -deoblique -prefix $output_dir/$subj.dist_AP $output_dir/temp+orig
 #	rm $output_dir/temp*
 #	
 #	foreach run ($list_run)
 #		cd $raw_dir/$run
 #		Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
 #		-gert_outdir $output_dir -gert_quit_on_err
 #		3dWarp -deoblique -prefix $output_dir/func.$subj.$run $output_dir/temp+orig
 #		rm $output_dir/temp*
 #		
 #		cd $raw_dir/${run}_SBREF
 #		Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
 #		-gert_outdir $output_dir -gert_quit_on_err
 #		3dWarp -deoblique -prefix $output_dir/SBREF.$subj.$run $output_dir/temp+orig
 #		rm $output_dir/temp*
 #	end
 #
 #	# ==================================================================
 #	########
 #	# Func # : Despiking (3dDespike) -> Slice Timing Correction (3dTshift) -> Motion Correct EPI (3dvolreg)
 #	########  -> Alignment (@auto_tlrc) -> Spatial Blurring -> Nuisance Regression -> Scaling
 #	
 #	cd $output_dir
 #	
 #	## tcat은 각 시간의 volume(sub-brick) 데이터를 시간에 대해 catenate 해준다는 뜻. 시간을 포함한 4차원 데이터로 merge.
 #	## apply 3dTcat to copy input dsets to results dir, while
 #	## removing the first 0 TRs
 #	#	foreach run ($list_run)
 #	#		3dTcat -prefix $output_dir/pb00.$subj.$run.tcat $preproc_dir/$subj/func.$subj.$run+orig'[0..$]'
 #	#	end
 #	## if you want to remove the first 2 TRs (TR indices 0 and 1), use [2..$] instead of [0..$]
 #	## 2..$ -> $는 just a variable which means the very end of that array. Only keeping volumes two to the very end 라는 뜻.
 #	
 #	## data check: compute outlier fraction for each volume
 #	## Calculate number of 'outliers' a 3D+time dataset, at each time point, and writes the results to stdout.
 #	## outliers -> MAD (Mean Absolute Deviation). If the MAD is 10, that means that at the RT we have an average of five median absolute deviations from the mean. Usually about 5.5 MAD is considered an outlier.
 #	touch out.pre_ss_warn.txt
 #	set npol = 4
 #	foreach run ($list_run)
 #		# ================================= outcount =================================
 #		## The formula that we use for polort, which is applied by afni_proc.py and by "3dDeconvolve -polort A", is pnum = 1 + floor(run_duration/150), where times are in seconds. Yes, pnum would be the order of polynomial used in 3dToutcount or 3dDeconvolve, while run_duration is the duration of the run in seconds (regardless of the number of time points).
 #		3dToutcount -automask -fraction -polort $npol -legendre func.$subj.$run+orig > outcount.$subj.$run.1D
 #		## polort = the polynomial order of the baseline model
 #		if ( `1deval -a outcount.$subj.$run.1D"{0}" -expr "step(a-0.4)"` ) then
 #			echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> out.$subj.pre_ss_warn.txt
 #		endif
 #	end
 #	## catenate outlier counts into a single time series
 #	cat outcount.$subj.r0?.1D > outcount.$subj.r_all.1D
 #	#================================ despike =================================
 #	## truncate spikes in each voxel's time series:
 #	foreach run ($list_run)
 #		3dDespike -NEW -nomask -prefix pb00.$subj.$run.despike func.$subj.$run+orig
 #	end
 #	# ================================= tshift (pb01) =================================
 #	## slice timing alignment on volumes (default is -time 0)
 #	## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
 #	foreach run ($list_run)
 #		3dTshift -tzero 0 -quintic -prefix pb01.$subj.$run.tshift pb00.$subj.$run.despike+orig
 #	end
 #	## tzero : to interpolate all the slices as though they were all acquired at the beginning of each TR.
 #	## quintic : 5th order of polynomial
	# ================================= blip: B0-distortion correction =================================
	## copy external -blip_forward_dset dataset
	3dTcat -prefix $output_dir/blip_forward $output_dir/$subj.dist_AP+orig
	## copy external -blip_reverse_dset dataset
	3dTcat -prefix $output_dir/blip_reverse $output_dir/$subj.dist_PA+orig
	
	## compute blip up/down non-linear distortion correction for EPI
	
	## create median datasets from forward and reverse time series
	3dTstat -median -prefix rm.blip.med.fwd blip_forward+orig
	3dTstat -median -prefix rm.blip.med.rev blip_reverse+orig
	
	## automask the median datasets
	3dAutomask -apply_prefix rm.blip.med.masked.fwd rm.blip.med.fwd+orig
	3dAutomask -apply_prefix rm.blip.med.masked.rev rm.blip.med.rev+orig
	
	## compute the midpoint warp between the median datasets
	3dQwarp -plusminus -pmNAMES Rev For		\
		-pblur 0.05 0.05 -blur -1 -1		\
		-noweight -minpatch 9				\
		-source rm.blip.med.masked.rev+orig	\
		-base rm.blip.med.masked.fwd+orig	\
		-prefix blip_warp
	
	## warp median datasets (forward and each masked) for QC checks
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
		-source rm.blip.med.fwd+orig \
		-prefix blip_med_for
	
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
		-source rm.blip.med.masked.fwd+orig \
		-prefix blip_med_for_masked
	
	3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig \
		-source rm.blip.med.masked.rev+orig \
		-prefix blip_med_rev_masked
	
	# warp EPI time series data
	foreach run ($list_run)
		3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
			-source pb01.$subj.$run.tshift+orig \
			-prefix pb01.$subj.$run.blip
	end
 #	# ================================== Align Anatomy with EPI ==================================
 #	cd $output_dir
 #	## align anatomical datasets to EPI registration base (default: anat2epi):
 #	align_epi_anat.py -anat2epi -anat $subj.anat.unifize+orig -anat_has_skull no \
 #	    -epi SBREF.$subj.r01+orig -epi_base 3 \
 #	    -epi_strip 3dAutomask \
 #	    -suffix _al_junk -check_flip \
 #	    -volreg off -tshift off -ginormous_move \
 #	    -cost lpa -align_centers yes
 #	## -cost nmi : weired result in the multiband8 protocol
 #	## -cost lpa (local pearson correlation)
 #	# ================================== register and warp (pb02) ========================
	cd $output_dir
 #	foreach run ($list_run)
 #		## register each volume to the base
 #		3dvolreg -verbose -zpad 1 -cubic -base SBREF.$subj.r01+orig'[0]' \
 #			-1Dfile dfile.$subj.$run.1D -prefix rm.epi.volreg.$subj.$run           \
 #			-1Dmatrix_save mat.$run.vr.aff12.1D  \
 #			pb01.$subj.$run.blip+orig
 #	
 #		## create an all-1 dataset to mask the extents of the warp
 #		3dcalc -overwrite -a pb01.$subj.$run.blip+orig -expr 1 -prefix rm.$subj.epi.all1
 #	
 #		## catenate volreg, epi2anat and tlrc transformations
 #		cat_matvec -ONELINE $subj.anat.unifize+tlrc::WARP_DATA \
 #			-I $subj.anat.unifize_al_junk_mat.aff12.1D \
 #			-I mat.$run.vr.aff12.1D > mat.$subj.$run.warp.aff12.1D
 #	
 #		## apply catenated xform : volreg, epi2anat and tlrc
 #		3dAllineate -base $subj.anat.unifize+tlrc \
 #			-input pb01.$subj.$run.blip+orig \
 #			-1Dmatrix_apply mat.$subj.$run.warp.aff12.1D \
 #			-mast_dxyz $res   -prefix rm.epi.nomask.$subj.$run # $res는 original data의 resolution과 맞춤e
 #	
 #		## warp the all-1 dataset for extents masking
 #		3dAllineate -base $subj.anat.unifize+tlrc \
 #			-input rm.$subj.epi.all1+orig \
 #			-1Dmatrix_apply mat.$subj.$run.warp.aff12.1D \
 #			-final NN -quiet \
 #			-mast_dxyz $res  -prefix rm.epi.1.$subj.$run
 #	
 #		## make an extents intersection mask of this run
 #		3dTstat -min -prefix rm.epi.min.$subj.$run rm.epi.1.$subj.$run+tlrc    # -----NEED CHECK-----
 #	end
 #	
	## make a single file of registration params
	cat dfile.$subj.r0?.1D > dfile.$subj.r_all.1D
	
	## create the extents mask: mask_epi_extents+tlrc
	## (this is a mask of voxels that have valid data at every TR)
	## (only 1 run, so just use 3dcopy to keep naming straight)
	3dcopy rm.epi.min.$subj.r01+tlrc mask_epi_extents.$subj
	
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
 #	rm $output_dir/pb00.*
 #	rm $output_dir/pb01.*
 #	# ==================================================================
	echo "subject $subj completed!"
end
