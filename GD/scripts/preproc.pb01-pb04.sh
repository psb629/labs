#!/bin/tcsh

set res = 2.683
set fwhm = 4
set thresh_motion = 0.4

#set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15 38)
# outliers : 29, 31
# No data : 19
set subj_list = (11)

set run_list = (`count -digits 2 1 6`)
# ================================= directories =================================
set data_dir = ~/Desktop/GD/fmri_data/preproc_data

 #set root_dir = /Volumes/WD_HDD1/GD
set root_dir = ~/Desktop/GD
set fmri_dir = $root_dir/fmri_data
set preproc_dir = $fmri_dir/preproc_data
# ================================= preprocessing step =================================
foreach nn ($subj_list)

	set subj = GD$nn

	# assign an output directory
	set output_dir = $preproc_dir/$subj/preprocessed
	if ( ! -d $output_dir ) then
		mkdir -p -m 755 $output_dir
	endif

	# ==================================================================
	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########

	cd $output_dir
	## Will copy only the dataset with the given view (orig, acpc, tlrc).
	3dcopy $preproc_dir/$subj/$subj.MPRAGE+orig $subj.anat+orig
	# ================================= skull-striping =================================
	3dSkullStrip -input $subj.anat+orig -prefix $subj.anat.ss -orig_vol
	# ================================= unifize =================================
	## this program can be a useful step to take BEFORE 3dSkullStrip, since the latter program can fail if the input volume is strongly shaded -- 3dUnifize will (mostly) remove such shading artifacts.
	3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5
	# ================================== tlrc ==================================
	## warp anatomy to standard space, input dataset must be in the current directory:
	cd $output_dir
	@auto_tlrc -base ~/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
	## find attribute WARP_DATA in dataset; -I, invert the transformation:
	## cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D ## == $subj.anat.unifize.Xat.1D
	3dAFNItoNIFTI -prefix anat_final.$subj.nii.gz $subj.anat.unifize+tlrc

	# ==================================================================
	########
	# Func # : Despiking (3dDespike) -> Slice Timing Correction (3dTshift) -> Motion Correct EPI (3dvolreg)
	########  -> Alignment (@auto_tlrc) -> Spatial Blurring -> Nuisance Regression -> Scaling

	cd $output_dir

	## tcat은 각 시간의 volume(sub-brick) 데이터를 시간에 대해 catenate 해준다는 뜻. 시간을 포함한 4차원 데이터로 merge.
	## apply 3dTcat to copy input dsets to results dir, while
	## removing the first 0 TRs
 #	foreach run ($run_list)
 #		3dTcat -prefix $output_dir/pb00.$subj.r$run.tcat $preproc_dir/$subj/func.$subj.r$run+orig'[0..$]'
 #	end
	## if you want to remove the first 2 TRs (TR indices 0 and 1), use [2..$] instead of [0..$]
	## 2..$ -> $는 just a variable which means the very end of that array. Only keeping volumes two to the very end 라는 뜻.

	## data check: compute outlier fraction for each volume
	## Calculate number of 'outliers' a 3D+time dataset, at each time point, and writes the results to stdout.
	## outliers -> MAD (Mean Absolute Deviation). If the MAD is 10, that means that at the RT we have an average of five median absolute deviations from the mean. Usually about 5.5 MAD is considered an outlier.
	touch out.pre_ss_warn.txt
	set npol = 4
	foreach run ($run_list)
		# ================================= outcount =================================
		## The formula that we use for polort, which is applied by afni_proc.py and by "3dDeconvolve -polort A", is pnum = 1 + floor(run_duration/150), where times are in seconds. Yes, pnum would be the order of polynomial used in 3dToutcount or 3dDeconvolve, while run_duration is the duration of the run in seconds (regardless of the number of time points).
		3dToutcount -automask -fraction -polort $npol -legendre $preproc_dir/$subj/func.$subj.r$run+orig > outcount.$subj.r$run.1D
		## polort = the polynomial order of the baseline model
		if ( `1deval -a outcount.$subj.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
			echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> out.$subj.pre_ss_warn.txt
		endif
	end
	## catenate outlier counts into a single time series
	cat outcount.$subj.r0?.1D > outcount.$subj.r_all.1D
	#================================ despike =================================
	## truncate spikes in each voxel's time series:
	foreach run ($run_list)
		3dDespike -NEW -nomask -prefix pb00.$subj.r$run.despike $preproc_dir/$subj/func.$subj.r$run+orig
	end
	# ================================= tshift (pb01) =================================
	## slice timing alignment on volumes (default is -time 0)
	## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
	foreach run ($run_list)
		3dTshift -tzero 0 -quintic -prefix pb01.$subj.r$run.tshift pb00.$subj.r$run.despike+orig
	end
	## tzero : to interpolate all the slices as though they were all acquired at the beginning of each TR.
	## quintic : 5th order of polynomial
	# ================================= blip: B0-distortion correction =================================
	## copy external -blip_forward_dset dataset
	3dTcat -prefix $output_dir/blip_forward $preproc_dir/$subj/dist.AP.$subj+orig
	## copy external -blip_reverse_dset dataset
	3dTcat -prefix $output_dir/blip_reverse $preproc_dir/$subj/dist.PA.$subj+orig

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
	foreach run ($run_list)
		3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
			-source pb01.$subj.r$run.tshift+orig \
			-prefix pb01.$subj.r$run.blip
	end
	# ================================== Align Anatomy with EPI ==================================
	cd $output_dir
	## align anatomical datasets to EPI registration base (default: anat2epi):
	align_epi_anat.py -anat2epi -anat $subj.anat.unifize+orig -anat_has_skull no \
	    -epi $preproc_dir/$subj/SBREF.$subj.r04+orig -epi_base 3 \
	    -epi_strip 3dAutomask \
	    -suffix _al_junk -check_flip \
	    -volreg off -tshift off -ginormous_move \
	    -cost lpa -align_centers yes
	## -cost nmi : weired result in the multiband8 protocol
	## -cost lpa (local pearson correlation)
	# ================================== register and warp (pb02) ========================
	foreach run ($run_list)
		## register each volume to the base
		3dvolreg -verbose -zpad 1 -cubic -base $preproc_dir/$subj/SBREF.$subj.r04+orig'[0]' \
			-1Dfile dfile.$subj.r$run.1D -prefix rm.epi.volreg.$subj.r$run           \
			-1Dmatrix_save mat.r$run.vr.aff12.1D  \
			pb01.$subj.r$run.blip+orig

		## create an all-1 dataset to mask the extents of the warp
		3dcalc -overwrite -a pb01.$subj.r$run.blip+orig -expr 1 -prefix rm.$subj.epi.all1

		## catenate volreg, epi2anat and tlrc transformations
		cat_matvec -ONELINE $subj.anat.unifize+tlrc::WARP_DATA -I $subj.anant.unifize_al_junk_mat.aff12.1D -I \
			mat.r$run.vr.aff12.1D > mat.$subj.r$run.warp.aff12.1D

		## apply catenated xform : volreg, epi2anat and tlrc
		3dAllineate -base $subj.anat.unifize+tlrc \
			-input pb01.$subj.r$run.blip+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-mast_dxyz $res   -prefix rm.epi.nomask.$subj.r$run # $res는 original data의 resolution과 맞춤.

		## warp the all-1 dataset for extents masking
		3dAllineate -base $subj.anat.unifize+tlrc \
			-input rm.$subj.epi.all1+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-final NN -quiet \
			-mast_dxyz $res  -prefix rm.epi.1.$subj.r$run

		## make an extents intersection mask of this run
		3dTstat -min -prefix rm.epi.min.$subj.r$run rm.epi.1.$subj.r$run+tlrc    # -----NEED CHECK-----
	end

	## make a single file of registration params
	cat dfile.$subj.r0?.1D > dfile.$subj.r_all.1D

	## create the extents mask: mask_epi_extents+tlrc
	## (this is a mask of voxels that have valid data at every TR)
	## (only 1 run, so just use 3dcopy to keep naming straight)
	3dcopy rm.epi.min.$subj.r04+tlrc mask_epi_extents.$subj

	## and apply the extents mask to the EPI data
	## (delete any time series with missing data)
	foreach run ($run_list)
		3dcalc -a rm.epi.nomask.$subj.r$run+tlrc -b mask_epi_extents.$subj+tlrc \
			-expr 'a*b' -prefix pb02.$subj.r$run.volreg
	end
	# ================================================= blur (pb03) =================================================
	## blur each volume of each run
	foreach run ($run_list)
		3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.r$run.blur \
			pb02.$subj.r$run.volreg+tlrc
	end
	## For each run, blur each volume by a $fwhm mm FWHM (Full Width at Half Max) Gaussian kernel
	## $fwhm -> 4 is default, 6 is common

	# ================================================= mask =================================================
	## create 'full_mask' dataset (union mask)
	## create a 'brain' mask from the EPI data (dilate 1 voxel)

	foreach run ($run_list)
		3dAutomask -dilate 1 -prefix rm.mask_r$run pb03.$subj.r$run.blur+tlrc
	end
	## 3dAutomaks  :  Input dataset is EPI 3D+time, or a skull-stripped anatomical. Output dataset is a brain-only mask dataset.
	## -dilate nd  = Dilate the mask outwards 'nd' times.

	## create union of inputs, output type is byte
	3dmask_tool -inputs rm.mask_r0?+tlrc.HEAD -union -prefix full_mask.$subj
	## 3dmask_tool  -  for combining/dilating/eroding/filling mask

	## ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
	##      (resampled from tlrc anat). resample은 resolution을 맞춰 sampling을 다시 하는 것. resolution을 낮추면 down sampling하는 것.
	3dresample -master full_mask.$subj+tlrc -input $subj.anat.unifize+tlrc -prefix rm.resam.anat
	## convert to binary anat mask; fill gaps and holes
	3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj

	# ================================= scale (pb04) ==================================
	## scale each voxel time series to have a mean of 100 (be sure no negatives creep in)
	## (subject to a range of [0,200])
	foreach run ($run_list)
		3dTstat -prefix rm.mean_r$run pb03.$subj.r$run.blur+tlrc
		3dcalc -float -a pb03.$subj.r$run.blur+tlrc -b rm.mean_r$run+tlrc -c mask_epi_extents.$subj+tlrc \
			-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.r$run.scale
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
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -demean -write motion_demean.$subj.1D
	## compute motion parameter derivatives (just to have)
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.1D
	## create censor file motion_${subj}_censor.1D, for censoring motion
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}

	## subjA_enorm.1D is the euclidean norm of the derivative, before the extreme mask is applied.
	## -censor_prev_TR : for each censored TR, also censor previous

	foreach run ($run_list)
		1d_tool.py -infile dfile.$subj.r$run.1D -set_nruns 1 -demean -write motion_demean.$subj.r$run.1D
		1d_tool.py -infile dfile.$subj.r$run.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.r$run.1D
		1d_tool.py -infile dfile.$subj.r$run.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}.r$run
	end

	## compute motion magnitude time series: the Euclidean norm
	## (sqrt(sum squares)) of the motion parameter derivatives
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 \
		-derivative  -collapse_cols euclidean_norm \
		-write motion_{$subj}.eucl_norm.1D

	foreach run ($run_list)
		1d_tool.py -infile dfile.$subj.r$run.1D -set_nruns 1 \
			-derivative  -collapse_cols euclidean_norm     \
			-write motion_{$subj}.r$run.eucl_norm.1D
	end
	# ==================================================================
	echo "subject $subj completed!"
end
