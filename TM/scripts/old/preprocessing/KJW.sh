#!/bin/tcsh
# =========================== auto block: setup ============================
# script setup
# take note of the AFNI version
afni -ver

set subj_list = (KJW)

set res = 2
set fwhm = 4
set thresh_motion = 0.5
set runs = (`count -digits 2 1 5`)

set TM_dir = /clmnlab/TM
set root_dir = $TM_dir/fMRI_data/raw_data
set preproc_dir = $TM_dir/fMRI_data/preproc_data
# =========================== auto block: Preprocessing step ============================
foreach subj ($subj_list)

	set output_dir = $preproc_dir/$subj

	if ( ! -d $output_dir ) then
		mkdir -m 777 $output_dir
	else
		echo "output dir ${output_dir} already exists"
	endif

	set dist_PA = $root_dir/$subj/DISTORTION_CORR_2MM_PA_0002
	set dist_AP = $root_dir/$subj/DISTORTION_CORR_64CH_PA_POLARITY_INVERT_TO_AP_0003
	set resting_dir = $root_dir/$subj/A-P_REST_MB3_2ISO_0004
	set run1_dir = $root_dir/$subj/RUN1_MB3_2ISO_0005
	set run2_dir = $root_dir/$subj/RUN2_MB3_2ISO_0006
	set run3_dir = $root_dir/$subj/RUN3_MB3_2ISO_0007
	set run4_dir = $root_dir/$subj/RUN4_MB3_2ISO_0009
	set run5_dir = $root_dir/$subj/RUN5_MB3_2ISO_0010
	set anat_dir = $root_dir/$subj/T1_MPRAGE_SAG_1_0ISO_0008

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

	cd $resting_dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/func.$subj.r00 $output_dir/temp+orig
	rm $output_dir/temp*

	cd $run1_dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/func.$subj.r01 $output_dir/temp+orig
	rm $output_dir/temp*

	cd $run2_dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/func.$subj.r02 $output_dir/temp+orig
	rm $output_dir/temp*

	cd $run3_dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/func.$subj.r03 $output_dir/temp+orig
	rm $output_dir/temp*

	cd $run4_dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/func.$subj.r04 $output_dir/temp+orig
	rm $output_dir/temp*

	cd $run5_dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/func.$subj.r05 $output_dir/temp+orig
	rm $output_dir/temp*

	cd $anat_dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/anat.$subj $output_dir/temp+orig
	rm $output_dir/temp*

end

# =========================== auto block: Preprocessing step ============================
# assign output directory name
set output_dir = preprocessed

foreach subj ($subj_list)

	# assign working directory name
	set work_dir = $preproc_dir/$subj

	# Change directory
	cd $work_dir

	# verify that the results directory does not yet exist
	if ( ! -d $output_dir ) then
		# create results and stimuli directories
		mkdir -m 777 $output_dir
	else
		echo output dir "preprocessed" already exists
	endif

	# ============================ auto block: tcat (pb00) ============================
	# apply 3dTcat to copy input dsets to results dir, while
	# removing the first 0 TRs

	foreach run ($runs)
		3dTcat -prefix $work_dir/$output_dir/pb00.$subj.r$run.tcat func.$subj.r$run+orig'[0..$]'
	end

	# enter the results directory (can begin processing data)
	cd $output_dir

	# copy the selected skull-stripped MPRAGE
	#3dcopy $root_dir/$subj/$subj.MPRAGE+orig $subj.MPRAGE+orig
	3dcopy $preproc_dir/$subj/anat.$subj+orig $subj.MPRAGE+orig
	# -------------------------------------------------------


	# ========================== auto block: outcount ==========================
	# data check: compute outlier fraction for each volume
	touch out.pre_ss_warn.txt
	set npol = 5
	foreach run ($runs)
		3dToutcount -automask -fraction -polort $npol -legendre pb00.$subj.r$run.tcat+orig > outcount.r$run.1D
		# outliers at TR 0 might suggest pre-steady state TRs
		if ( `1deval -a outcount.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
			echo "** TR #0 outliers: possible pre-steady state TRs in run $run" >> out.pre_ss_warn.txt
		endif
	end

	# catenate outlier counts into a single time series
	cat outcount.r*.1D > outcount_rall.1D

	#MOLLY ADDED ================================ despike =================================
	# apply 3dDespike to each run
	foreach run ( $runs )
        3dDespike -NEW -nomask -prefix pb00.$subj.r$run.despike pb00.$subj.r$run.tcat+orig
	end
	# ================================= tshift (pb01) =================================
	# time shift data so all slice timing is the same (slice timing correction)
	foreach run ( $runs )
        3dTshift -tzero 0 -quintic -prefix pb01.$subj.r$run.tshift pb00.$subj.r$run.despike+orig
	end
	# YJS comment: quintic = certain level of interpolation (5th order?)
	# to check slice timing info: 3dinfo -VERB pb~~ | grep offset

	3dSkullStrip -input $subj.MPRAGE+orig -prefix $subj.ssMPRAGE -orig_vol
	3dUnifize -input $subj.ssMPRAGE+orig -prefix $subj.UnissMPRAGE -GM

	# =============================== align ==================================
	# for e2a: compute anat alignment transformation to EPI registration base
	# (new anat will be intermediate, stripped, epi_$subjID.anat_ns+orig)
	align_epi_anat.py -anat2epi -anat $subj.UnissMPRAGE+orig -anat_has_skull no	\
	-epi pb01.$subj.r01.tshift+orig -epi_base 2 -epi_strip  3dAutomask			\
	-suffix _al_junk -check_flip -volreg off -tshift off -ginormous_move		\
	-deoblique off																\
	-cost nmi  -align_centers yes

	# ================================== blip ==================================
	# compute blip up/down non-linear distortion correction for EPI
	
	# copy external -blip_forward_dset dataset
	3dTcat -prefix $output_dir/blip_forward $work_dir/dist.AP.$subj+orig
	# copy external -blip_reverse_dset dataset
	3dTcat -prefix $output_dir/blip_reverse $work_dir/dist.PA.$subj+orig

	# create median datasets from forward and reverse time series
	3dTstat -median -prefix rm.blip.med.fwd blip_forward+orig
	3dTstat -median -prefix rm.blip.med.rev blip_reverse+orig

	# automask the median datasets
	3dAutomask -apply_prefix rm.blip.med.masked.fwd rm.blip.med.fwd+orig
	3dAutomask -apply_prefix rm.blip.med.masked.rev rm.blip.med.rev+orig

	# compute the midpoint warp between the median datasets
	3dQwarp -plusminus -pmNAMES Rev For		\
	-pblur 0.05 0.05 -blur -1 -1			\
	-noweight -minpatch 9					\
	-source rm.blip.med.masked.rev+orig		\
	-base   rm.blip.med.masked.fwd+orig		\
	-prefix blip_warp

	# warp median datasets (forward and each masked) for QC checks
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig	\
	-source rm.blip.med.fwd+orig							\
	-prefix blip_med_for

	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig	\
	-source rm.blip.med.masked.fwd+orig						\
	-prefix blip_med_for_masked

	3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig	\
	-source rm.blip.med.masked.rev+orig						\
	-prefix blip_med_rev_masked

	# warp EPI time series data
	foreach run ( $runs )
		3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig	\
		-source pb01.$subj.r$run.tshift+orig					\
		-prefix pb01.$subj.r$run.blip
	end
	# ================================== tlrc ==================================
	# warp anatomy to standard space
	@auto_tlrc -base MNI152_T1_2009c+tlrc -input $subj.UnissMPRAGE+orig -no_ss

	# store forward transformation matrix in a text file
	cat_matvec $subj.UnissMPRAGE+tlrc::WARP_DATA -I > warp.anat.Xat.1D

	# ================================= volreg =================================
	# align each dset to base volume, align to anat, warp to tlrc space

	# verify that we have a +tlrc warp dataset
	if ( ! -f $subj.UnissMPRAGE+tlrc.HEAD ) then
	echo "** missing +tlrc warp dataset: $subj.UnissMPRAGE+tlrc.HEAD"
	exit
	endif

	# ================================== register and warp (epi/pb02) =======================================
	foreach run ( $runs )
	# register each volume to the base
	3dvolreg -verbose -zpad 1 -cubic -base pb01.$subj.r01.tshift+orig'[2]'					\
	-1Dfile dfile.r$run.1D -prefix rm.epi.volreg.r$run -1Dmatrix_save mat.r$run.vr.aff12.1D	\
	pb01.$subj.r$run.tshift+orig

	# YJS comment: 1dfile is a text file of 6 columns describing amount of discrepency

	# create an all-1 dataset to mask the extents of the warp
	3dcalc -overwrite -a pb01.$subj.r$run.tshift+orig -expr 1 -prefix rm.epi.all1

	# catenate volreg, epi2anat and tlrc transformations
	cat_matvec -ONELINE $subj.UnissMPRAGE+tlrc::WARP_DATA -I $subj.UnissMPRAGE_al_junk_mat.aff12.1D -I	\
	mat.r$run.vr.aff12.1D > mat.r$run.warp.aff12.1D

	# apply catenated xform : volreg, epi2anat and tlrc
	3dAllineate -base $subj.UnissMPRAGE+tlrc -input pb01.$subj.r$run.tshift+orig		\
	-1Dmatrix_apply mat.r$run.warp.aff12.1D -mast_dxyz $res -prefix rm.epi.nomask.r$run

	# warp the all-1 dataset for extents masking
	3dAllineate -base $subj.UnissMPRAGE+tlrc -input rm.epi.all1+orig -1Dmatrix_apply mat.r$run.warp.aff12.1D	\
	-mast_dxyz $res -final NN -quiet -prefix rm.epi.1.r$run

	# make an extents intersection mask of this run
	3dTstat -min -prefix rm.epi.min.r$run rm.epi.1.r$run+tlrc
	# 4d(epi.1) -> 3d(epi.min)
	end

	# make a single file of registration params
	cat dfile.r*.1D > dfile_rall.1D # YJS comment: concatenating motion parameters of all runs

	# create the extents mask: mask_epi_extents+tlrc
	# (this is a mask of voxels that have valid data at every TR)
	# (only 1 run, so just use 3dcopy to keep naming straight)
	3dcopy rm.epi.min.r01+tlrc mask_epi_extents

	# and apply the extents mask to the EPI data
	# (delete any time series with missing data)
	foreach run ( $runs )
		3dcalc -a rm.epi.nomask.r$run+tlrc -b mask_epi_extents+tlrc -expr 'a*b' -prefix pb02.$subj.r$run.volreg
	end

	# create an anat_final dataset, aligned with stats
	3dcopy $subj.UnissMPRAGE+tlrc anat_final.$subj

	# -----------------------------------------
	# warp anat follower datasets (affine)
	3dAllineate -source $subj.UnissMPRAGE+orig -master anat_final.$subj+tlrc -final wsinc5 -1Dmatrix_apply warp.anat.Xat.1D	\
	-prefix anat_w_skull_warped

	# ================================================= blur (pb03) =================================================
	# blur each volume of each run
	foreach run ( $runs )
		3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.r$run.blur pb02.$subj.r$run.volreg+tlrc
	end

	# ================================================= mask =================================================
	# create 'full_mask' dataset (union mask)
	foreach run ( $runs )
		3dAutomask -dilate 1 -prefix rm.mask_r$run pb03.$subj.r$run.blur+tlrc
	end
	# create union of inputs, output type is byte
	3dmask_tool -inputs rm.mask_r*+tlrc.HEAD -union -prefix full_mask.$subj
	# ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
	#      (resampled from tlrc anat)
	3dresample -master full_mask.$subj+tlrc -input $subj.UnissMPRAGE+tlrc -prefix rm.resam.anat
	# convert to binary anat mask; fill gaps and holes
	3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj

	# ================================= scale (pb04) ==================================
	# scale each voxel time series to have a mean of 100 (be sure no negatives creep in)
	# (subject to a range of [0,200])
	foreach run ( $runs )
		3dTstat -prefix rm.mean_r$run pb03.$subj.r$run.blur+tlrc
		3dcalc -float -a pb03.$subj.r$run.blur+tlrc -b rm.mean_r$run+tlrc -c mask_epi_extents+tlrc	\
		-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.r$run.scale
	end
	# ================================ regress =================================
	# compute de-meaned motion parameters (for use in regression)
	1d_tool.py -infile dfile_rall.1D -set_nruns 1 -demean -write motion_demean.$subj.1D
	# compute motion parameter derivatives (just to have)
	1d_tool.py -infile dfile_rall.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.1D
	# create censor file motion_${subj}_censor.1D, for censoring motion
	1d_tool.py -infile dfile_rall.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}

	foreach run ( $runs )
		1d_tool.py -infile dfile.r$run.1D -set_nruns 1 -demean -write motion_demean.$subj.r$run.1D
		1d_tool.py -infile dfile.r$run.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.r$run.1D
		1d_tool.py -infile dfile.r$run.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}.r$run
	end
	# ================================ bandpass filtering  =================================
	foreach run ( $runs )
		3dTproject -polort 0 -input pb04.$subj.r$run.scale+tlrc.HEAD -mask full_mask.$subj+tlrc -passband 0.01 0.1 \
		-censor motion_${subj}.r{$run}_censor.1D -cenmode ZERO -ort motion_demean.$subj.r$run.1D  -prefix bp_demean.$subj.r$run
	end
	# ================== auto block: generate review scripts ===================
	# generate a review script for the unprocessed EPI data
	gen_epi_review.py -script @epi_review.$subj -dsets pb00.$subj.r*.tcat+orig.HEAD

	# ========================== auto block: finalize ==========================
	# YJS added: concatenate runs
	#3dTcat -prefix pb04.$subj.allRuns pb04.$subj.r01.scale+tlrc pb04.$subj.r02.scale+tlrc pb04.$subj.r03.scale+tlrc pb04.$subj.r04.scale+tlrc pb04.$subj.r05.scale+tlrc pb04.$subj.r06.scale+tlrc
	
	# ================== delect p00 and p01 ===================
	# delect useless files such as p00 and p01
	rm ./pb00.*.HEAD ./pb00.*.BRIK
	rm ./pb01.*.HEAD ./pb01.*.BRIK
	echo "subject $subj completed"
end
