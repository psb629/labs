#!/bin/zsh

## ================================================ ##
while (( $# )); do
	key="$1"
	case $key in
		-s | --subject)
			subj="$2"
		;;
	esac
	shift ##takes one argument
done
## ================================================ ##
dir_root="/mnt/ext5/DRN/fmri_data"
dir_preproc="$dir_root/preproc_data/$subj"
## ================================================ ##
cd $dir_preproc
3dAFNItoNIFTI	\
	-prefix $dir_preproc/errts.$subj.scale.tproject.nii	\
	$dir_preproc/errts.$subj.tproject+tlrc.HEAD
3dTproject									\
	-polort 0								\
	-input pb0?.$subj.r0?.volreg+tlrc.HEAD	\
	-mask full_mask.$subj+tlrc.HEAD			\
	-censor censor_${subj}_combined_2.1D	\
	-cenmode ZERO							\
	-ort X.nocensor.xmat.1D					\
	-prefix errts.$subj.volreg.tproject.nii
