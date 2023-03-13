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
dir_root="/mnt/ext5/DRN/fmri_data/preproc_data/$subj"
##############################################################
dir_output=$dir_root
cd $dir_root

3dTproject									\
	-polort 0								\
	-input									\
		pb04.DRN04.r01.volreg+tlrc.HEAD		\
		pb04.DRN04.r02.volreg+tlrc.HEAD		\
		pb04.DRN04.r03.volreg+tlrc.HEAD		\
		pb04.DRN04.r04.volreg+tlrc.HEAD		\
		pb04.DRN04.r05.volreg+tlrc.HEAD		\
		pb04.DRN04.r06.volreg+tlrc.HEAD		\
	-mask full_mask.DRN04+tlrc.HEAD			\
	-censor censor_DRN04_combined_2.1D		\
	-cenmode ZERO							\
	-ort X.nocensor.xmat.1D					\
	-prefix $dir_output/errts.DRN04.volreg.tproject.nii
