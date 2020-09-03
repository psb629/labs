#!/bin/tcsh
# =========================== auto block: setup ============================
# script setup
# take note of the AFNI version
afni -ver

set subj_list = (TML27)

set res = 2
set fwhm = 4
set thresh_motion = 0.5

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

	set resting_dir = $root_dir/$subj/REST_MB3_2ISO_0002
	set anat_dir = $root_dir/$subj/T1_MPRAGE_SAG_1_0ISO_0006

#	cd $resting_dir
#	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
#	-gert_outdir $output_dir -gert_quit_on_err
#	3dWarp -deoblique -prefix $output_dir/func.$subj.r00 $output_dir/temp+orig
#	rm $output_dir/temp*

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
	# enter the results directory (can begin processing data)
	cd $output_dir

	# copy the selected skull-stripped MPRAGE
	#3dcopy $root_dir/$subj/$subj.MPRAGE+orig $subj.MPRAGE+orig
	3dcopy $preproc_dir/$subj/anat.$subj+orig $subj.MPRAGE+orig
	# -------------------------------------------------------

	# ================================= tshift (pb01) =================================
	# time shift data so all slice timing is the same (slice timing correction)
	# YJS comment: quintic = certain level of interpolation (5th order?)
	# to check slice timing info: 3dinfo -VERB pb~~ | grep offset

	3dSkullStrip -input $subj.MPRAGE+orig -prefix $subj.ssMPRAGE -orig_vol
	3dUnifize -input $subj.ssMPRAGE+orig -prefix $subj.UnissMPRAGE -GM

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
	# create an anat_final dataset, aligned with stats
	3dcopy $subj.UnissMPRAGE+tlrc anat_final.$subj

	# -----------------------------------------
	# warp anat follower datasets (affine)
	3dAllineate -source "$subj.UnissMPRAGE+orig" -master "anat_final.$subj+tlrc" -final "wsinc5" \
	-1Dmatrix_apply "warp.anat.Xat.1D" -prefix "anat_w_skull_warped"

end
