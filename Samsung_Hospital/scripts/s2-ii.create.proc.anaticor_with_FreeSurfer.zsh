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

##############################################################

## I/O path, same as above, following earlier steps
dir_FreeSurfer="$dir_root/FreeSurfer/$phase"
if [[ ! -d $dir_FreeSurfer ]]; then
	mkdir -p -m 755 $dir_FreeSurfer
fi

## FS function
recon-all								\
	-sid		$subj					\
	-sd			$dir_FreeSurfer			\
	-i			$dir_raw/$subj.T1.nii	\
	-all								\

## AFNI-SUMA function: convert FS output
@SUMA_Make_Spec_FS						\
	-NIFTI								\
	-fspath		$dir_FreeSurfer/$subj	\
	-sid		$subj

##############################################################

 #3dQwarp -allineate -blur 0 3 										\
 #	-base "/usr/local/afni/abin/MNI152_2009_template_SSW.nii.gz"	\
 #	-source "$dir_FreeSurfer/$subj/SUMA/brain.nii.gz" 					\
 #	-prefix "$dir_FreeSurfer/$subj/SUMA/brain_qw.nii"

##############################################################
 
dir_output="$dir_root/preproc_data/$phase.anaticor/with_FreeSurfer/$subj"
tlrc_base="MNI152_2009_template_SSW.nii.gz"

dir_script="/home/sungbeenpark/Github/labs/Samsung_Hospital/scripts/afni_proc.py/$phase/with_FreeSurfer"
if [ ! -d $dir_script ]; then
	mkdir -p -m 755 $dir_script
fi
cd $dir_script
afni_proc.py																				\
	-subj_id					$subj														\
	-out_dir					$dir_output													\
	-blocks						despike tshift align tlrc volreg blur mask scale regress	\
	-radial_correlate_blocks	tcat volreg													\
	-copy_anat					"$dir_FreeSurfer/$subj/SUMA/brain.nii.gz"					\
	-anat_has_skull				'no'														\
	-anat_follower				anat_w_skull anat "$dir_FreeSurfer/$subj/SUMA/T1.nii.gz"	\
	-anat_follower_ROI			aaseg anat													\
								"$dir_FreeSurfer/$subj/SUMA/aparc.a2009s+aseg_REN_all.nii.gz"	\
	-anat_follower_ROI			aeseg epi														\
								"$dir_FreeSurfer/$subj/SUMA/aparc.a2009s+aseg_REN_all.nii.gz"	\
	-anat_follower_ROI			FSvent epi "$dir_FreeSurfer/$subj/SUMA/fs_ap_latvent.nii.gz"	\
	-anat_follower_ROI			FSWe epi "$dir_FreeSurfer/$subj/SUMA/fs_ap_wm.nii.gz"			\
	-anat_follower_erode		FSvent FSWe													\
	-dsets						"$dir_raw/$subj.func.nii"									\
	-tcat_remove_first_trs		2															\
	-align_unifize_epi			'yes'														\
	-align_opts_aea																			\
	-cost						lpc+ZZ														\
	-giant_move																				\
	-check_flip																				\
	-tlrc_base					$tlrc_base													\
	-tlrc_NL_warp																			\
	-volreg_align_to			MIN_OUTLIER													\
	-volreg_align_e2a																		\
	-volreg_tlrc_warp																		\
	-blur_size					4															\
	-mask_epi_anat				'yes'														\
	-regress_motion_per_run																	\
	-regress_ROI_PC				FSvent 3													\
	-regress_ROI_PC_per_run		FSvent														\
	-regress_make_corr_vols		aeseg FSvent												\
	-regress_anaticor_fast																	\
	-regress_anaticor_label		FSWe														\
	-regress_censor_motion		0.4															\
	-regress_censor_outliers	0.05														\
	-regress_apply_mot_types	demean deriv												\
	-regress_est_blur_epits																	\
	-regress_est_blur_errts																	\
	-html_review_style			pythonic
 #	-tlrc_NL_warped_dsets		"$dir_FreeSurfer/$subj/SUMA/T1qw.nii" 						\
 #								"$dir_FreeSurfer/$subj/SUMA/T1qw_Allin.aff12.1D"			\
 #								"$dir_FreeSurfer/$subj/SUMA/T1qw_WARP.nii"					\
