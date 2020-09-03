#!/bin/tcsh

set res = 2.683
set fwhm = 4
set thresh_motion = 0.4

set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26)

set root_dir = /Users/clmn/Desktop/GD
set raw_dir = $root_dir/fMRI_data/raw_data
set out_dir = /Volumes/T7SSD1/GD/fMRI_data
set preproc_dir = $out_dir/preproc_data
# ================================= preprocessing step =================================
foreach subj ($subj_list)

	set subj_raw_dir = $raw_dir/$subj
	chmod -R 777 $subj_raw_dir	# To prevent 'Unreadable Error'
	set dist_PA = $subj_raw_dir/dist_PA
	set dist_AP = $subj_raw_dir/dist_AP
	set MPRAGE = $subj_raw_dir/MPRAGE
	set SBREF_r04 = $subj_raw_dir/r04_SBREF

	set runs = (`count -digits 2 1 7`)

	# assign output directory name
	set subj_preproc_dir = $preproc_dir/$subj
	set output_dir = $subj_preproc_dir
	if (! -d $output_dir ) then
		mkdir -m 777 $output_dir
	else
		echo "output dir($output_dir) already exists!"
	endif
	# ================================= rename the raw_data_dir =================================
	set pnAP = dist_AP
	set pnPA = dist_PA
	set pnRest_1 = rest_SBREF
	set pnRest_2 = rest
	set pn1_1 = r01_SBREF
	set pn1_2 = r01
	set pn2_1 = r02_SBREF
	set pn2_2 = r02
	set pn3_1 = r03_SBREF
	set pn3_2 = r03
	set pnT1 = MPRAGE
	set pn4_1 = r04_SBREF
	set pn4_2 = r04
	set pn5_1 = r05_SBREF
	set pn5_2 = r05
	set pn6_1 = r06_SBREF
	set pn6_2 = r06
	set pn7_1 = r07_SBREF
	set pn7_2 = r07

	cd $subj_raw_dir
	if (! -d $pnPA ) then
		# DISTORTION_CORR_64CH_PA_0002 -> pnPA
		mv ./DISTOR*_PA_00* ./$pnPA
		# DISTORTION_CORR_64CH_PA_POLARITY_INVERT_TO_AP_0003 -> pnAP
		mv ./DISTOR*_PA_POLARITY_* ./$pnAP
		# A-P_REST_MUITIBAND8_EPI_CMRR_SBREF_0004 -> pnRest_1
		mv ./A-P_REST_*_CMRR_SBREF_* ./$pnRest_1
		# A-P_REST_MUITIBAND8_EPI_CMRR_0005 -> pnRest_2
		mv ./A-P_REST_*_CMRR_00* ./$pnRest_2
		# RUN2_MUITIBAND8_EPI_CMRR_SBREF_0006 -> pn1_1
		mv ./RUN2_*_CMRR_SBREF_* ./$pn1_1
		# RUN2_MUITIBAND8_EPI_CMRR_0007 -> pn1_2
		mv ./RUN2_*_CMRR_00* ./$pn1_2
		# RUN3_MUITIBAND8_EPI_CMRR_SBREF_0008 -> pn2_1
		mv ./RUN3_*_CMRR_SBREF_* ./$pn2_1
		# RUN3_MUITIBAND8_EPI_CMRR_0009 -> pn2_2
		mv ./RUN3_*_CMRR_00* ./$pn2_2
		# RUN4_MUITIBAND8_EPI_CMRR_SBREF_0010 -> pn3_1
		mv ./RUN4_*_CMRR_SBREF_* ./$pn3_1
		# RUN4_MUITIBAND8_EPI_CMRR_0011 -> pn3_2
		mv ./RUN4_*_CMRR_00* ./$pn3_2
		# T1_MPRAGE_SAG_0_7ISO_0012 -> pnT1
		mv ./T1_MPRAGE_* ./$pnT1
		# RUN5_MUITIBAND8_EPI_CMRR_SBREF_0013 -> pn4_1
		mv ./RUN5_*_CMRR_SBREF_* ./$pn4_1
		# RUN5_MUITIBAND8_EPI_CMRR_0014 -> pn4_2
		mv ./RUN5_*_CMRR_00* ./$pn4_2
		# RUN6_MUITIBAND8_EPI_CMRR_SBREF_0015 -> pn5_1
		mv ./RUN6_*_CMRR_SBREF_* ./$pn5_1
		# RUN6_MUITIBAND8_EPI_CMRR_0016 -> pn5_2
		mv ./RUN6_*_CMRR_00* ./$pn5_2
		# RUN7_MUITIBAND8_EPI_CMRR_SBREF_0017 -> pn6_1
		mv ./RUN7_*_CMRR_SBREF_* ./$pn6_1
		# RUN7_MUITIBAND8_EPI_CMRR_0018 -> pn6_2
		mv ./RUN7_*_CMRR_00* ./$pn6_2
		# RUN8_MUITIBAND8_EPI_CMRR_SBREF_0019 -> pn7_1
		mv ./RUN8_*_CMRR_SBREF_* ./$pn7_1
		# RUN8_MUITIBAND8_EPI_CMRR_0020 -> pn7_2
		mv ./RUN8_*_CMRR_00* ./$pn7_2
	endif
	# ================================= setp 00 : convert =================================
	cd $dist_PA
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/dist.PA.$subj $output_dir/temp+orig
	rm $output_dir/temp*

	cd $dist_AP
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/dist.AP.$subj $output_dir/temp+orig
	rm $output_dir/temp*

	foreach run ($runs)
		cd $subj_raw_dir/r$run
		Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
		-gert_outdir $output_dir -gert_quit_on_err
		3dWarp -deoblique -prefix $output_dir/func.$subj.r$run $output_dir/temp+orig
		rm $output_dir/temp*
	end

	cd $SBREF_r04
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/SBREF.$subj.r04 $output_dir/temp+orig
	rm $output_dir/temp*

	cd $MPRAGE
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/$subj.MPRAGE $output_dir/temp+orig
	rm $output_dir/temp*
	# ==================================================================
	
	cd $subj_preproc_dir

	# assign output directory name
	set output_dir = $subj_preproc_dir/preprocessed
	if (! -d $output_dir ) then
		mkdir -m 777 $output_dir
	else
		echo "output dir($output_dir) already exists!"
	endif

	# ================================= step01 : tcat & tshift =================================
	# ================================= tcat (pb00) =================================
	# tcat은 각 시간의 volume(sub-brick) 데이터를 시간에 대해 catenate 해준다는 뜻. 시간을 포함한 4차원 데이터로 merge.
	# apply 3dTcat to copy input dsets to results dir, while
	# removing the first 0 TRs
	foreach run ($runs)
		3dTcat -prefix $output_dir/pb00.$subj.r$run.tcat func.$subj.r$run+orig'[0..$]'
	end
	# if you want to remove the first 2 TRs (TR indices 0 and 1), use [2..$] instead of [0..$]
	# 2..$ -> $는 just a variable which means the very end of that array. Only keeping volumes two to the very end 라는 뜻.

	# enter the results directory (can begin processing data)
	cd $output_dir

	3dcopy $subj_preproc_dir/$subj.MPRAGE+orig $subj.anat+orig
	# Will copy only the dataset with the given view (orig, acpc, tlrc).
	# ========================== auto block: outcount ==========================
	# data check: compute outlier fraction for each volume
	# Calculate number of 'outliers' a 3D+time dataset, at each time point, and writes the results to stdout.
	# outliers -> MAD (Mean Absolute Deviation). If the MAD is 10, that means that at the RT we have an average of five median absolute deviations from the mean. Usually about 5.5 MAD is considered an outlier.
	touch out.pre_ss_warn.txt
	set npol = 4
	foreach run ($runs)
		# The formula that we use for polort, which is applied by afni_proc.py and by "3dDeconvolve -polort A", is pnum = 1 + floor(run_duration/150), where times are in seconds. Yes, pnum would be the order of polynomial used in 3dToutcount or 3dDeconvolve, while run_duration is the duration of the run in seconds (regardless of the number of time points).
		# if scanning time = 420s, so npol = 3
		3dToutcount -automask -fraction -polort $npol -legendre               \
		pb00.$subj.r$run.tcat+orig > outcount.$subj.r$run.1D
		# outliers at TR 0 might suggest pre-steady state TRs
		# -fraction option to 3dToutcount, so that the output is no longer a voxel count,
		# but is that count divided by the number of voxels in the computed automask
		# -fraction  = Output the fraction of (masked) voxels which are outliers at each time point, instead of the count.
		# -polort nn = Detrend each voxel time series with polynomials of order 'nn' prior to outlier estimation.
		if ( `1deval -a outcount.$subj.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
			echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> out.pre_ss_warn.txt
		endif
	end
	# catenate outlier counts into a single time series
	cat outcount.$subj.r*.1D > outcount_rall.$subj.1D
	# in Terminal,
	# cat outcount_rall.1D  'SHOWS' the fraction of outliers for the total individual time points.
	# 1dplot outcount_rall.1D  'SHOWS'  the graph of outliers with x-axis time, y-axis the fraction value.
	# 1deval -a outcount_rall.1D -expr 't * step(a-0.05)' | grep -v '0'
	# -> '~' = certain threshold. Any TRs which are greater than 0.05 or TRs which have more than 5% of the voxels as outliers
	# -> grep -v '0'  = only look at nonzero entries
	# 1dplot -one '1D: 450@0.05' outcount_rall.1D -> x축은 0부터 450까지, 높이 0.05인 직선을 그어서 0.05 이상의 outlier가 어디인지 그래프로 확인.
	# AFNI에서는 pb00.~.tcat 파일을 열고 graph 켜서 edge of brain 영역을 확인.
	# Edge of brain gives you a better sense of if there was any head motion contributing to a huge increase in signal.

	# MOLLY ADDED ================================ despike =================================
	# apply 3dDespike to each run
	# Removes 'spikes' from the 3D+time input dataset and writes a new dataset with the spike values replaced by something
	# more pleasing to the eye.
	foreach run ($runs)
		3dDespike -NEW -nomask -prefix pb00.$subj.r${run}.despike pb00.$subj.r${run}.tcat+orig
	end
	# -NEW  = Use the 'new' method for computing the fit, which should be faster than the L1 method for long time
	# series (200+ time points); however, the results are similar but NOT identical. [29 Nov 2013]
	# -nomask  = Process all voxels

	# -prefix -> tells me what to label the output of the file and the command is done

	# ================================= tshift (pb01) =================================
	# t shift or slice time correction
	# time shift data so all slice timing is the same
	# 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
	foreach run ($runs)
		3dTshift -tzero 0 -quintic -prefix pb01.$subj.r${run}.tshift \
		pb00.$subj.r${run}.despike+orig
	end
	# tzero -> to interpolate all the slices as though they were all acquired at the beginning of each TR.
	# quintic -> 5th order of polynomial
	# ==================================================================
	# ================================= step02 : blip =================================
	# copy external -blip_forward_dset dataset
	3dTcat -prefix $output_dir/blip_forward $subj_preproc_dir/dist.AP.$subj+orig
	# copy external -blip_reverse_dset dataset
	3dTcat -prefix $output_dir/blip_reverse $subj_preproc_dir/dist.PA.$subj+orig

	# ================================== blip ==================================
	# compute blip up/down non-linear distortion correction for EPI

	# create median datasets from forward and reverse time series
	3dTstat -median -prefix rm.blip.med.fwd blip_forward+orig
	3dTstat -median -prefix rm.blip.med.rev blip_reverse+orig

	# automask the median datasets
	3dAutomask -apply_prefix rm.blip.med.masked.fwd rm.blip.med.fwd+orig
	3dAutomask -apply_prefix rm.blip.med.masked.rev rm.blip.med.rev+orig

	# compute the midpoint warp between the median datasets
	3dQwarp -plusminus -pmNAMES Rev For                           \
		-pblur 0.05 0.05 -blur -1 -1                          \
		-noweight -minpatch 9                                 \
		-source rm.blip.med.masked.rev+orig                   \
		-base   rm.blip.med.masked.fwd+orig                   \
		-prefix blip_warp

	# warp median datasets (forward and each masked) for QC checks
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
		-source rm.blip.med.fwd+orig                     \
		-prefix blip_med_for

	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
		-source rm.blip.med.masked.fwd+orig              \
		-prefix blip_med_for_masked

	3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig          \
		-source rm.blip.med.masked.rev+orig              \
		-prefix blip_med_rev_masked

	# warp EPI time series data
	foreach run ( $runs )
		3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig      \
			-source pb01.$subj.r$run.tshift+orig         \
			-prefix pb01.$subj.r$run.blip
	end

	# ==================================================================
	# ================================== step03 : volreg ==================================
	# ================================= align ==================================
	# for e2a: compute anat alignment transformation to EPI registration base
	# (new anat will be intermediate, stripped, epi_$subjID.anat_ns+orig)

	# 3dSkullStrip -input VOL -prefix VOL_PREFIX
	3dSkullStrip -input $subj.anat+orig -prefix $subj.sSanat -orig_vol
	3dUnifize -input $subj.sSanat+orig -prefix $subj.UnisSanat -GM

	# - align EPI to anatomical datasets or vice versa
	align_epi_anat.py -anat2epi -anat $subj.UnisSanat+orig -anat_has_skull no    \
		-epi $subj_preproc_dir/SBREF.$subj.r04+orig   -epi_base 0                                \
		-epi_strip 3dAutomask                                                         \
		-suffix _al_junk                     -check_flip                              \
		-volreg off    -tshift off           -ginormous_move                          \
		-cost lpa      -align_centers yes
		# -cost nmi : weired result in the multiband8 protocol
		# -cost lpa (local pearson correlation)

	# ================================== tlrc ==================================
	# warp anatomy to standard space
	#@auto_tlrc -base TT_N27+tlrc -input $subj.UnisSanat+orig -no_ss
	@auto_tlrc -base MNI152_T1_2009c+tlrc.HEAD -input $subj.UnisSanat+orig -no_ss -init_xform AUTO_CENTER #-init_xform AUTO_CENTER

	cat_matvec $subj.UnisSanat+tlrc::WARP_DATA -I > warp.anat.Xat.1D

	if ( ! -f $subj.UnisSanat+tlrc.HEAD ) then
		echo "** missing +tlrc warp dataset: $subj.UnisSanat+tlrc.HEAD"
		exit
	endif

	# ================================== register and warp (pb02) ========================
	foreach run ($runs)
		# register each volume to the base
		3dvolreg -verbose -zpad 1 -cubic -base $subj_preproc_dir/SBREF.$subj.r04+orig'[0]'         \
			-1Dfile dfile.$subj.r$run.1D -prefix rm.epi.volreg.$subj.r$run           \
			-1Dmatrix_save mat.r$run.vr.aff12.1D  \
			pb01.$subj.r$run.blip+orig

		# create an all-1 dataset to mask the extents of the warp
		3dcalc -overwrite -a pb01.$subj.r$run.blip+orig -expr 1 -prefix rm.$subj.epi.all1

		# catenate volreg, epi2anat and tlrc transformations
		cat_matvec -ONELINE $subj.UnisSanat+tlrc::WARP_DATA -I $subj.UnisSanat_al_junk_mat.aff12.1D -I \
			mat.r$run.vr.aff12.1D > mat.$subj.r$run.warp.aff12.1D

		# apply catenated xform : volreg, epi2anat and tlrc
		3dAllineate -base $subj.UnisSanat+tlrc \
			-input pb01.$subj.r$run.blip+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-mast_dxyz $res   -prefix rm.epi.nomask.$subj.r$run # $res는 original data의 resolution과 맞춤.

		# warp the all-1 dataset for extents masking
		3dAllineate -base $subj.UnisSanat+tlrc \
			-input rm.$subj.epi.all1+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-final NN -quiet \
			-mast_dxyz $res  -prefix rm.epi.1.$subj.r$run

		# make an extents intersection mask of this run
		3dTstat -min -prefix rm.epi.min.$subj.r$run rm.epi.1.$subj.r$run+tlrc    # -----NEED CHECK-----
	end

	# make a single file of registration params
	cat dfile.$subj.r*.1D > dfile_rall.$subj.1D

	# ----------------------------------------
	# create the extents mask: mask_epi_extents+tlrc
	# (this is a mask of voxels that have valid data at every TR)
	# (only 1 run, so just use 3dcopy to keep naming straight)
	3dcopy rm.epi.min.$subj.r04+tlrc mask_epi_extents.$subj

	# and apply the extents mask to the EPI data
	# (delete any time series with missing data)
	foreach run ($runs)
		3dcalc -a rm.epi.nomask.$subj.r$run+tlrc -b mask_epi_extents.$subj+tlrc \
			-expr 'a*b' -prefix pb02.$subj.r$run.volreg
	end

	# create an anat_final dataset, aligned with stats
	3dcopy $subj.UnisSanat+tlrc anat_final.$subj

	# warp anat follower datasets (affine)     - skull 있는 데이터를 warp하는 목적
	3dAllineate -source $subj.anat+orig \
		-master anat_final.$subj+tlrc \
		-final wsinc5 -1Dmatrix_apply warp.anat.Xat.1D \
		-prefix anat_w_skull_warped.$subj
	# ==================================================================
	# ================================== step04 : blur2scl ==================================
	# ================================================= blur =================================================
	# blur each volume of each run
	foreach run ($runs)
		3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.r${run}.blur \
			pb02.$subj.r${run}.volreg+tlrc
	end
	# For each run, blur each volume by a $fwhm mm FWHM (Full Width at Half Max) Gaussian kernel
	# $fwhm -> 4 is default, 6 is common

	# ================================================= mask =================================================
	# create 'full_mask' dataset (union mask)
	# create a 'brain' mask from the EPI data (dilate 1 voxel)

	foreach run ($runs)
		3dAutomask -dilate 1 -prefix rm.mask_r${run} pb03.$subj.r${run}.blur+tlrc
	end
	# 3dAutomaks  :  Input dataset is EPI 3D+time, or a skull-stripped anatomical. Output dataset is a brain-only mask dataset.
	# -dilate nd  = Dilate the mask outwards 'nd' times.

	# create union of inputs, output type is byte
	3dmask_tool -inputs rm.mask_r*+tlrc.HEAD -union -prefix full_mask.$subj
	# 3dmask_tool  -  for combining/dilating/eroding/filling mask

	# ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
	#      (resampled from tlrc anat). resample은 resolution을 맞춰 sampling을 다시 하는 것. resolution을 낮추면 down sampling하는 것.
	3dresample -master full_mask.$subj+tlrc -input $subj.UnisSanat+tlrc -prefix rm.resam.anat
	# convert to binary anat mask; fill gaps and holes
	3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj

	# ================================= scale ==================================
	# scale each voxel time series to have a mean of 100 (be sure no negatives creep in)
	# (subject to a range of [0,200])
	foreach run ($runs)
		3dTstat -prefix rm.mean_r${run} pb03.$subj.r${run}.blur+tlrc
		3dcalc -float -a pb03.$subj.r${run}.blur+tlrc -b rm.mean_r${run}+tlrc -c mask_epi_extents.$subj+tlrc \
			-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.r${run}.scale
	end
	# ==================================================================
	# ================================== step05 : rgr_motion ==================================
	# ================================ regress =================================

	# 1d_tool.py will be used to create a censor file just before 3dDeconvolve

	# Example 7a. Output temporal derivative of motion regressors.  There are
	# 9 runs in dfile_rall.1D, and derivatives are applied per run.
	# 1d_tool.py -infile dfile_rall.1D -set_nruns 9 \
	# -derivative -write motion.deriv.1D

	# -demean : demean each run (new mean of each run = 0.0)
	# -derivative : take the temporal derivative of each vector (done as first backward difference)
	# compute de-meaned motion parameters (for use in regression)
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -demean -write motion_demean.$subj.1D
	# compute motion parameter derivatives (just to have)
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.1D
	# create censor file motion_${subj}_censor.1D, for censoring motion
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}

	# subjA_enorm.1D is the euclidean norm of the derivative, before the extreme mask is applied.
	# -censor_prev_TR : for each censored TR, also censor previous

	foreach run ($runs)
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1 -demean -write motion_demean.$subj.r${run}.1D
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.r${run}.1D
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}.r${run}
	end

	# compute motion magnitude time series: the Euclidean norm
	# (sqrt(sum squares)) of the motion parameter derivatives
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1      \
		-derivative  -collapse_cols euclidean_norm      \
		-write motion_{$subj}.eucl_norm.1D

	foreach run ($runs)
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1    \
			-derivative  -collapse_cols euclidean_norm     \
			-write motion_{$subj}.r${run}.eucl_norm.1D
	end
	# ==================================================================
	# ================== delect p00 and p01 ===================
	# delect useless files such as p00 and p01
	rm ./pb00.*.HEAD ./pb00.*.BRIK
	rm ./pb01.*.HEAD ./pb01.*.BRIK
	rm ./rm.*
	# ================== full mask is converted to .nii.gz file ================== #
	set subj_fullmask = $subj_preproc_dir/preprocessed/full_mask.{$subj}+tlrc.
	set full_mask_dir = $out_dir/masks/full_masks
	if (! -d $full_mask_dir) then
		mkdir -m 777 -p $full_mask_dir
	endif
	set pref = $full_mask_dir/full_mask.{$subj}.nii.gz
	if (! -e $pref) then
		3dAFNItoNIFTI -prefix $pref $subj_fullmask
	endif
	# ================== gzip ================== #
	cd $subj_preproc_dir
	gzip -1v *.BRIK

	cd ./preprocessed
	gzip -1v *.BRIK
	# ==================================================================
	echo "subject $subj completed!"
end

#$root_dir/scripts/GLM1_test.sh
