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
dir_root="/mnt/ext4/GL/fmri_data/preproc_data.SSKim/$subj"
##############################################################
dir_output=$dir_root
cd $dir_root

3dTproject									\
	-polort 0								\
	-input									\
		pb02.$subj.r02.volreg+tlrc.HEAD		\
		pb02.$subj.r03.volreg+tlrc.HEAD		\
		pb02.$subj.r04.volreg+tlrc.HEAD		\
		pb02.$subj.r05.volreg+tlrc.HEAD		\
	-mask full_mask.$subj+tlrc.HEAD			\
	-censor motion_$subj.r02_05.censor.1D	\
	-cenmode ZERO							\
	-ort motion_demean.$subj.r02_05.1D		\
	-prefix $dir_output/tproject.errts.$subj.volreg.r02_05.nii
