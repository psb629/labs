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
		-p | --phase)
			phase="$2"
		;;
	esac
	shift ##takes one argument
done

##############################################################

dir_root="/mnt/ext5/SMC/fmri_data"
dir_raw=`find $dir_root/raw_data/$phase -maxdepth 1 -type d -name "$subj*"`
dir_mask="$dir_root/masks"

dir_output="$dir_root/preproc_data/$phase.anaticor/without_FreeSurfer/$subj"

dir_script="/home/sungbeenpark/Github/labs/Samsung_Hospital/scripts/afni_proc.py/$phase/without_FreeSurfer"
if [ ! -d $dir_script ]; then
	mkdir -p -m 755 $dir_script
fi
cd $dir_script
 
 #tlrc_base='MNI152_T1_2009c+tlrc'
tlrc_base='TT_N27+tlrc'

dxyz=2.0

afni_proc.py																			\
	-subj_id				$subj														\
	-out_dir				$dir_output													\
	-blocks					despike tshift align tlrc volreg blur mask scale regress	\
	-copy_anat				$dir_raw/$subj.T1.nii										\
	-dsets					$dir_raw/$subj.func.nii										\
	-tcat_remove_first_trs	2															\
	-align_unifize_epi		'yes'														\
	-align_opts_aea																		\
	-cost					lpc+ZZ														\
	-giant_move																			\
	-check_flip																			\
	-tlrc_base				$tlrc_base													\
	-tlrc_NL_warp																		\
	-volreg_align_to		MIN_OUTLIER													\
	-volreg_align_e2a																	\
	-volreg_tlrc_warp																	\
	-volreg_warp_dxyz		$dxyz														\
	-blur_size				4															\
	-mask_segment_anat		'yes'														\
	-mask_segment_erode		'yes'														\
	-mask_import			Tvent "$dir_mask/template_ventricle_2.0mm.nii"				\
	-mask_intersect			Svent CSFe Tvent											\
	-mask_epi_anat			'yes'														\
	-regress_motion_per_run																\
	-regress_ROI_PC			Svent 3														\
	-regress_ROI_PC_per_run	Svent														\
	-regress_make_corr_vols	WMe Svent													\
	-regress_anaticor_fast																\
	-regress_censor_motion		0.4														\
	-regress_censor_outliers	0.05													\
	-regress_apply_mot_types	demean deriv											\
	-regress_est_blur_epits																\
	-regress_est_blur_errts																\
	-html_review_style pythonic
 #	-regress_run_clustsim	'yes
