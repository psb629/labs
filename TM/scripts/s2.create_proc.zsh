#!/bin/zsh

## ==================================================== ##
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
	esac
	shift ##takes one argument
done
## ==================================================== ##
dir_root="/mnt/ext4/TM/fmri_data"
dir_raw="$dir_root/raw_data/$subj"
dir_preproc="$dir_root/preproc_data/$subj"

dir_script="/home/sungbeenpark/Github/labs/TM/scripts/afni_proc.py"
if [ ! -d $dir_script ]; then
	mkdir -p -m 755 $dir_script
fi

dir_output=$dir_preproc
## ==================================================== ##
dsets=(`find $dir_raw -type f -name "func.r??.$subj.nii" | sort -t ' ' -k 1`)
## ==================================================== ##
cd $dir_script
afni_proc.py	\
	-subj_id				$subj	\
	-out_dir				$dir_output		\
	-blocks					despike tshift align tlrc volreg blur mask scale regress	\
	-copy_anat				$dir_raw/T1.$subj.nii										\
	-anat_has_skull			yes				\
	-anat_uniform_method	unifize			\
	-anat_unif_GM			yes				\
	-dsets					$dsets			\
	-radial_correlate_blocks	tcat volreg	\
	-tcat_remove_first_trs	0	\
	-tlrc_base				MNI152_2009_template_SSW.nii.gz	\
	-tlrc_NL_warp	\
	-align_opts_aea	\
	-cost					lpa				\
	-giant_move		\
	-check_flip		\
	-volreg_align_to		MIN_OUTLIER		\
	-volreg_align_e2a		\
	-volreg_tlrc_warp		\
	-blur_size				4.0				\
	-mask_epi_anat			yes				\
	-regress_motion_per_run		\
	-regress_censor_motion		0.4			\
	-regress_censor_outliers	0.05		\
	-regress_apply_mot_types	demean deriv	\
	-html_review_style			pythonic
 #	-execute
