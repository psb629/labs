#!/bin/zsh

##############################################################
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-s | --subject)
			subj="$2"
		;;
		-d | --day)
			dd="$2"
		;;
	esac
	shift ##takes one argument
done
day="day$dd"
##############################################################
dir_root="/mnt/ext5/GP/fmri_data"
dir_raw="$dir_root/raw_data/$subj/$day"
dir_t1="$dir_root/raw_data/$subj/day1"
dir_preproc="$dir_root/preproc_data/$subj/$day"

dir_script="/home/sungbeenpark/Github/labs/GP/scripts/afni_proc.py/"
if [ ! -d $dir_script ]; then
	mkdir -p -m 755 $dir_script
fi
dir_output=$dir_preproc
 #if [ ! -d $dir_output ]; then
 #	mkdir -p -m 755 $dir_output
 #fi
##############################################################
cd $dir_script
afni_proc.py																			\
	-subj_id				$subj														\
	-script					proc_$subj.$day												\
	-out_dir				$dir_output													\
	-blocks					despike tshift align tlrc volreg blur mask scale regress	\
	-copy_anat				$dir_t1/MPRAGE.$subj.nii									\
	-anat_has_skull			yes															\
	-anat_uniform_method	unifize														\
	-anat_unif_GM			yes															\
	-dsets																				\
							$dir_raw/func.$subj.r01.nii									\
							$dir_raw/func.$subj.r02.nii									\
							$dir_raw/func.$subj.r03.nii									\
	-radial_correlate_blocks															\
							tcat volreg													\
	-blip_forward_dset		$dir_raw/dist_AP.$subj.nii									\
	-blip_reverse_dset		$dir_raw/dist_PA.$subj.nii									\
	-tlrc_base				MNI152_2009_template_SSW.nii.gz								\
	-tlrc_NL_warp																		\
	-align_opts_aea																		\
							-cost			lpa											\
							-giant_move													\
							-check_flip													\
	-volreg_align_to		MIN_OUTLIER													\
	-volreg_align_e2a																	\
	-volreg_tlrc_warp																	\
	-blur_size				4.0															\
	-mask_epi_anat			yes															\
	-regress_motion_per_run																\
	-regress_censor_motion		0.4														\
	-regress_censor_outliers	0.05													\
	-regress_apply_mot_types	demean deriv											\
	-regress_est_blur_epits																\
	-regress_est_blur_errts																\
	-html_review_style			pythonic												\
	-execute
 #	-regress_run_clustsim	'yes
