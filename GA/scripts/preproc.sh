#!/bin/tcsh

set res = 2.683
set fwhm = 4
set thresh_motion = 0.4
# ===================================================
set id_list = (GA GB)
set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
set subj_list = ( 01 )
set run_list = (r01 r02 r03 r04 r05 r06)
# ===================================================
set root_dir = /Volumes/WD_HDD1/GA
set raw_dir = $root_dir/fmri_data/raw_data
# ===================================================
foreach ii ($id_list)
	foreach nn ($subj_list)
		set subj = $ii$nn
 #		set subj_dir = /Users/clmn/Desktop/GA/fmri_data/preproc_data/$nn
		set subj_dir = /Volumes/WD_HDD1/test/GA/fmri_data/preproc_data/$nn
		if ( ! -d $subj_dir ) then
			mkdir -p -m 755 $subj_dir
		endif
		# ================================= convert =================================
		cd $subj_dir
		set pname = T1.3D.$subj
		Dimon -infile_pat "$raw_dir/$subj/MPRAGE/*.IMA" \
			-gert_create_dataset -gert_to3d_prefix $pname \
			-gert_outdir $subj_dir -gert_quit_on_err
		3dWarp -deoblique -prefix $subj_dir/$subj.MPRAGE $subj_dir/$pname+orig
		3dAFNItoNIFTI -prefix $subj_dir/$subj.MPRAGE.nii.gz $subj_dir/$subj.MPRAGE+orig
		rm $subj_dir/GERT_Reco_dicom_* $subj_dir/dimon.files.run.* $subj_dir/${pname}* $subj_dir/$subj.MPRAGE+orig.*
		foreach run ($run_list)
			cd $subj_dir
			set pname = $run.3D.$subj
			Dimon -infile_pat "$raw_dir/$subj/$run/*.IMA" \
				-gert_create_dataset -gert_to3d_prefix $pname \
				-gert_outdir $subj_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $subj_dir/$subj.func.$run $subj_dir/$pname+orig
			3dAFNItoNIFTI -prefix $subj_dir/$subj.func.$run.nii.gz $subj_dir/$subj.func.$run+orig
		end
		rm $subj_dir/GERT_Reco_dicom_* $subj_dir/dimon.files.run.* $subj_dir/${pname}* $subj_dir/$subj.func.$run+orig.*
		if (-d $raw_dir/$subj/dist_PA) then
			cd $subj_dir
			set pname = PA.3D.$subj
			Dimon -infile_pat "$raw_dir/$subj/dist_PA/*.IMA" \
				-gert_create_dataset -gert_to3d_prefix $pname \
				-gert_outdir $subj_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $subj_dir/$subj.dist.PA $subj_dir/$pname+orig
			3dAFNItoNIFTI -prefix $subj_dir/$subj.dist.PA.nii.gz $subj_dir/$subj.dist.PA+orig
			rm $subj_dir/GERT_Reco_dicom_* $subj_dir/dimon.files.run.* $subj_dir/${pname}* $subj_dir/$subj.dist.PA+orig.*
		endif
		if (-d $raw_dir/$subj/dist_AP) then
			cd $subj_dir
			set pname = AP.3D.$subj
			Dimon -infile_pat "$raw_dir/$subj/dist_AP/*.IMA" \
				-gert_create_dataset -gert_to3d_prefix $pname \
				-gert_outdir $subj_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $subj_dir/$subj.dist.AP $subj_dir/$pname+orig
			3dAFNItoNIFTI -prefix $subj_dir/$subj.dist.AP.nii.gz $subj_dir/$subj.dist.AP+orig
			rm $subj_dir/GERT_Reco_dicom_* $subj_dir/dimon.files.run.* $subj_dir/${pname}* $subj_dir/$subj.dist.AP+orig.*
		endif
		# ==================================================================
		set output_dir = $subj_dir/preprocessed
		if ( ! -d $output_dir ) then
			mkdir -p -m 755 $output_dir
		endif
		# ================================= tcat (pb00) =================================
		## tcat은 각 시간의 volume(sub-brick) 데이터를 시간에 대해 catenate 해준다는 뜻. 시간을 포함한 4차원 데이터로 merge.
		## Will copy only the dataset with the given view (orig, acpc, tlrc).
 #		3dcopy $subj_dir/$subj.MPRAGE.nii.gz $output_dir/$subj.anat.nii.gz
		set anat = $subj_dir/$subj.MPRAGE.nii.gz
 #		foreach run ($run_list)
 #			3dTcat -prefix $output_dir/$subj.pb00.$run.tcat.nii.gz $subj_dir/$subj.func.$run.nii.gz'[0..$]' # removing the first 0 TRs
 #		end
		## if you want to remove the first 2 TRs (TR indices 0 and 1), use [2..$] instead of [0..$]
		## 2..$ -> $는 just a variable which means the very end of that array. Only keeping volumes two to the very end 라는 뜻.

		# ========================== outcount ==========================
		## data check: compute outlier fraction for each volume
		## Calculate number of 'outliers' a 3D+time dataset, at each time point, and writes the results to stdout.
		## outliers -> MAD (Mean Absolute Deviation). If the MAD is 10, that means that at the RT we have an average of five median absolute deviations from the mean. Usually about 5.5 MAD is considered an outlier.
		touch $output_dir/$subj.out.pre_ss_warn.txt
		set npol = 4
		foreach run ($run_list)
			## The formula that we use for polort, which is applied by afni_proc.py and by "3dDeconvolve -polort A", is pnum = 1 + floor(run_duration/150), where times are in seconds. Yes, pnum would be the order of polynomial used in 3dToutcount or 3dDeconvolve, while run_duration is the duration of the run in seconds (regardless of the number of time points).
			## if scanning time = 420s, so npol = 3
			set pb00_tcat  = $subj_dir/$subj.func.$run.nii.gz
			3dToutcount -automask -fraction -polort $npol -legendre $pb00_tcat > $output_dir/$subj.outcount.$run.1D
			## outliers at TR 0 might suggest pre-steady state TRs
			## -fraction option to 3dToutcount, so that the output is no longer a voxel count,
			## but is that count divided by the number of voxels in the computed automask
			## -fraction  = Output the fraction of (masked) voxels which are outliers at each time point, instead of the count.
			## -polort nn = Detrend each voxel time series with polynomials of order 'nn' prior to outlier estimation.
			if ( `1deval -a $output_dir/$subj.outcount.$run.1D"{0}" -expr "step(a-0.4)"` ) then
				echo "** TR #0 outliers: possible pre-steady state TRs in run $run" >> $output_dir/$subj.out.pre_ss_warn.txt
			endif
		end
		## catenate outlier counts into a single time series
		cat $output_dir/$subj.outcount.r*.1D > $output_dir/$subj.outcount_rall.1D
		## in Terminal,
		## cat outcount_rall.1D  'SHOWS' the fraction of outliers for the total individual time points.
		## 1dplot outcount_rall.1D  'SHOWS'  the graph of outliers with x-axis time, y-axis the fraction value.
		## 1deval -a outcount_rall.1D -expr 't * step(a-0.05)' | grep -v '0'
		## -> '~' = certain threshold. Any TRs which are greater than 0.05 or TRs which have more than 5% of the voxels as outliers
		## -> grep -v '0'  = only look at nonzero entries
		## 1dplot -one '1D: 450@0.05' outcount_rall.1D -> x축은 0부터 450까지, 높이 0.05인 직선을 그어서 0.05 이상의 outlier가 어디인지 그래프로 확인.
		## AFNI에서는 pb00.~.tcat 파일을 열고 graph 켜서 edge of brain 영역을 확인.
		## Edge of brain gives you a better sense of if there was any head motion contributing to a huge increase in signal.

		## MOLLY ADDED ================================ despike =================================
		## apply 3dDespike to each run
		## Removes 'spikes' from the 3D+time input dataset and writes a new dataset with the spike values replaced by something
		## more pleasing to the eye.
		foreach run ($run_list)
			3dDespike -NEW -nomask -prefix $output_dir/$subj.pb00.$run.despike.nii.gz $output_dir/$subj.pb00.$run.tcat.nii.gz
		end
		## -NEW  = Use the 'new' method for computing the fit, which should be faster than the L1 method for long time

		# ================================= tshift (pb01) =================================
		## t shift or slice time correction
		## time shift data so all slice timing is the same
		## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
 #		foreach run ($run_list)
 #			3dTshift -tzero 0 -quintic -prefix $output_dir/$subj.pb01.$run.tshift.nii.gz $output_dir/$subj.pb00.$run.despike.nii.gz		
 #		end
		## tzero -> to interpolate all the slices as though they were all acquired at the beginning of each TR.
		## quintic -> 5th order of polynomial

		# ================================= blip =================================
		if ((-f $subj_dir/$subj.dist.AP.nii.gz)&&(-f $subj_dir/$subj.dist.PA.nii.gz)) then
			## copy external -blip_forward_dset dataset
			3dTcat -prefix $output_dir/$subj.blip_forward.nii.gz $subj_dir/$subj.dist.AP.nii.gz
			## copy external -blip_reverse_dset dataset
			3dTcat -prefix $output_dir/$subj.blip_reverse.nii.gz $subj_dir/$subj.dist.PA.nii.gz
		
			## compute blip up/down non-linear distortion correction for EPI
			## create median datasets from forward and reverse time series
			3dTstat -median -prefix $output_dir/$subj.rm.blip.med.fwd.nii.gz $output_dir/$subj.blip_forward.nii.gz
			3dTstat -median -prefix $output_dir/$subj.rm.blip.med.rev.nii.gz $output_dir/$subj.blip_reverse.nii.gz
		
			## automask the median datasets
			3dAutomask -apply_prefix $output_dir/$subj.rm.blip.med.masked.fwd.nii.gz $output_dir/$subj.rm.blip.med.fwd.nii.gz
			3dAutomask -apply_prefix $output_dir/$subj.rm.blip.med.masked.rev.nii.gz $output_dir/$subj.rm.blip.med.rev.nii.gz
		
			## compute the midpoint warp between the median datasets
			3dQwarp -plusminus -pmNAMES Rev For \
				-pblur 0.05 0.05 -blur -1 -1 \
				-noweight -minpatch 9 \
				-source $output_dir/$subj.rm.blip.med.masked.rev.nii.gz \
				-base   $output_dir/$subj.rm.blip.med.masked.fwd.nii.gz \
				-prefix $output_dir/$subj.blip_warp.nii.gz
			## By default, this {prefix}_{pnNAME1}_WARP (source) and {prefix}_{pnNAME2}_WARP (base) files are save.
	
			## warp median datasets (forward and each masked) for QC checks
			3dNwarpApply -quintic -nwarp $output_dir/$subj.blip_warp_For_WARP.nii.gz \
				-source $output_dir/$subj.rm.blip.med.fwd.nii.gz \
				-prefix $output_dir/$subj.blip_med_for.nii.gz
		
			3dNwarpApply -quintic -nwarp $output_dir/$subj.blip_warp_For_WARP.nii.gz \
				-source $output_dir/$subj.rm.blip.med.masked.fwd.nii.gz \
				-prefix $output_dir/$subj.blip_med_for_masked.nii.gz
		
			3dNwarpApply -quintic -nwarp $output_dir/$subj.blip_warp_Rev_WARP.nii.gz \
				-source $output_dir/$subj.rm.blip.med.masked.rev.nii.gz \
				-prefix $output_dir/$subj.blip_med_rev_masked.nii.gz
		
			## warp EPI time series data
			foreach run ($run_list)
				## dataset is already aligned in time! ==>> output dataset is just a copy of input dataset (pb01.tshift = pb00.despike)
				set pb01_tshift = $output_dir/$subj.pb00.$run.despike.nii.gz
				3dNwarpApply -quintic -nwarp $output_dir/$subj.blip_warp_For_WARP.nii.gz \
					-source $pb01_tshift \
					-prefix $output_dir/$subj.pb01.$run.blip.nii.gz
			end
		endif

		# ================================= align ==================================
		## for e2a: compute anat alignment transformation to EPI registration base
		## (new anat will be intermediate, stripped, epi_$subjID.anat_ns+orig)
		3dSkullStrip -input $anat -prefix $output_dir/$subj.sSanat.nii.gz -orig_vol
		3dUnifize -input $output_dir/$subj.sSanat.nii.gz -prefix $output_dir/$subj.UnisSanat.nii.gz -GM
	
		## - align EPI to anatomical datasets or vice versa
		align_epi_anat.py -anat2epi -anat $output_dir/$subj.UnisSanat.nii.gz -anat_has_skull no \
			-epi $subj_dir/$subj.func.r03.nii.gz -epi_base 0 \
			-epi_strip 3dAutomask \
			-suffix _al_junk \
			-volreg off -tshift off -ginormous_move \
			-cost lpa -align_centers yes
			# -cost nmi : weired result in the multiband8 protocol
			# -cost lpa (local pearson correlation)

		# ================================== tlrc coordinate ==================================
		## warp anatomy to standard space
 #		3dcopy $output_dir/$subj.UnisSanat.nii.gz $output_dir/$subj.UnisSanat # @auto_tlrc seems to prefer HEAD, BRIK files to NII files
		cd $output_dir
		@auto_tlrc -base MNI152_T1_2009c+tlrc.HEAD -input $subj.UnisSanat.nii.gz \
			-prefix $subj.anat.final.nii.gz \
			-no_ss -init_xform AUTO_CENTER #-init_xform AUTO_CENTER

		cd $output_dir
		cat_matvec $subj.anat.final.nii.gz::WARP_DATA -I > $subj.warp.anat.Xat.1D
	
		if ( ! -f $output_dir/$subj.anat.final.nii.gz ) then
			echo "** missing +tlrc warp dataset: $subj.UnisSanat+tlrc.HEAD"
			exit
		endif

		# ================================== register and warp (pb02) ========================
 #		foreach run ($run_list)
 #			if (-f $output_dir/$subj.pb01.$run.blip.nii.gz) then
 #			# register each volume to the base
 #			3dvolreg -verbose -zpad 1 -cubic -base $subj_dir/$subj.func.r03.nii.gz'[0]'         \
 #				-1Dfile $output_dir/$subj.dfile.$run.1D -prefix $output_dir/$subj.rm.epi.volreg.$run \
 #				-1Dmatrix_save $output_dir/$subj.mat.$run.vr.aff12.1D \
 #				$output_dir/$subj.pb01.$run.blip.nii.gz
 #			else
 #				$pb01_tshift
 #			endif
 #	
 #			# create an all-1 dataset to mask the extents of the warp
 #			3dcalc -overwrite -a $output_dir/$subj.pb01.$run.blip.nii.gz -expr 1 -prefix $output_dir/$subj.rm.epi.all1
 #	
 #			# catenate volreg, epi2anat and tlrc transformations
 #			cat_matvec -ONELINE $subj.UnisSanat+tlrc::WARP_DATA -I $subj.UnisSanat_al_junk_mat.aff12.1D -I \
 #				mat.r$run.vr.aff12.1D > mat.$subj.r$run.warp.aff12.1D
 #	
 #			# apply catenated xform : volreg, epi2anat and tlrc
 #			3dAllineate -base $subj.UnisSanat+tlrc \
 #				-input pb01.$subj.r$run.blip+orig \
 #				-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
 #				-mast_dxyz $res   -prefix rm.epi.nomask.$subj.r$run # $res는 original data의 resolution과 맞춤.
 #	
 #			# warp the all-1 dataset for extents masking
 #			3dAllineate -base $subj.UnisSanat+tlrc \
 #				-input rm.$subj.epi.all1+orig \
 #				-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
 #				-final NN -quiet \
 #				-mast_dxyz $res  -prefix rm.epi.1.$subj.r$run
 #	
 #			# make an extents intersection mask of this run
 #			3dTstat -min -prefix rm.epi.min.$subj.r$run rm.epi.1.$subj.r$run+tlrc    # -----NEED CHECK-----
		end
 #	
 #		# make a single file of registration params
 #		cat dfile.$subj.r*.1D > dfile_rall.$subj.1D
 #	
 #		# ----------------------------------------
 #		# create the extents mask: mask_epi_extents+tlrc
 #		# (this is a mask of voxels that have valid data at every TR)
 #		# (only 1 run, so just use 3dcopy to keep naming straight)
 #		3dcopy rm.epi.min.$subj.r04+tlrc mask_epi_extents.$subj
 #	
 #		# and apply the extents mask to the EPI data
 #		# (delete any time series with missing data)
 #		foreach run ($runs)
 #			3dcalc -a rm.epi.nomask.$subj.r$run+tlrc -b mask_epi_extents.$subj+tlrc \
 #				-expr 'a*b' -prefix pb02.$subj.r$run.volreg
 #		end
 #	
 #		# create an anat_final dataset, aligned with stats
 #		3dcopy $subj.UnisSanat+tlrc anat_final.$subj
 #	
 #		# warp anat follower datasets (affine)     - skull 있는 데이터를 warp하는 목적
 #		3dAllineate -source $subj.anat+orig \
 #			-master anat_final.$subj+tlrc \
 #			-final wsinc5 -1Dmatrix_apply warp.anat.Xat.1D \
 #			-prefix anat_w_skull_warped.$subj
 #		# ==================================================================
	end
end
