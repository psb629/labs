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
	esac
	shift ##takes one argument
done
##############################################################
dir_root="/mnt/ext5/DRN/fmri_data"
dir_raw="$dir_root/raw_data/$subj"
dir_preproc="$dir_root/preproc_data/$subj"

dir_script="/home/sungbeenpark/Github/labs/DRN/scripts/afni_proc.py/"
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
	-out_dir				$dir_output													\
	-blocks					despike tshift align tlrc volreg blur mask scale regress	\
	-copy_anat				$dir_raw/T1.$subj.nii										\
	-anat_has_skull			yes															\
	-anat_uniform_method	unifize														\
	-anat_unif_GM			yes															\
	-dsets																				\
							$dir_raw/func.r01.$subj.nii									\
							$dir_raw/func.r02.$subj.nii									\
							$dir_raw/func.r03.$subj.nii									\
							$dir_raw/func.r04.$subj.nii									\
							$dir_raw/func.r05.$subj.nii									\
							$dir_raw/func.r06.$subj.nii									\
	-radial_correlate_blocks															\
							tcat volreg													\
	-tcat_remove_first_trs	12															\
	-blip_forward_dset		$dir_raw/func.r01.$subj.nii'[12]'							\
	-blip_reverse_dset		$dir_raw/dist_PA.$subj.nii									\
	-tlrc_base				MNI152_2009_template_SSW.nii.gz								\
	-tlrc_NL_warp																		\
	-align_opts_aea																		\
	-cost					lpa															\
	-giant_move																			\
	-check_flip																			\
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
	-html_review_style			pythonic
 #	-execute
 #	-regress_run_clustsim	'yes
