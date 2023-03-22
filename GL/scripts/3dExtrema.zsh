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
dir_root="/mnt/ext4/GL/fmri_data"
dir_mask="$dir_root/masks"
dir_preproc="$dir_root/preproc_data.SSKim/$subj"
dir_stat="$dir_root/stats/GLM.reward.4s_shifted.SSKim/$subj"
dir_output=$dir_stat
##############################################################
pname=$dir_output/"mask.3dExtrema.caudate.$subj.nii"
3dExtrema														\
	-volume -interior -quiet									\
	-maxima														\
	-mask_file $dir_mask/"mask.TTatlas.caudate.resampled.nii"	\
	-prefix $pname												\
	$dir_stat/stats.$subj+tlrc.HEAD'[Rew#0_Coef]'

3dmaskave													\
	-quiet													\
	-mask $pname											\
	$dir_preproc/"tproject.errts.$subj.volreg.r02_05.nii"	\
	>$dir_output/"ts.caudate.$subj.1D"
