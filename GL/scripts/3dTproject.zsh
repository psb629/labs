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
		--pb )
			pp="$2"
		;;
	esac
	shift ##takes one argument
done
##############################################################
case $pp in
	04 | '04' | 'pb04')
		pp=04
		pb='scale'
	;;
	*)
		pp=02
		pb='volreg'
	;;
esac
##############################################################
dir_root="/mnt/ext4/GL/fmri_data/preproc_data.SSKim/$subj"
##############################################################
dir_output=$dir_root
cd $dir_root

pname="$dir_output/tproject.errts.$subj.$pb.r02_05.nii"

if [ ! -f $pname ]; then
	3dTproject									\
		-polort 0								\
		-input									\
			pb$pp.$subj.r02.$pb+tlrc.HEAD		\
			pb$pp.$subj.r03.$pb+tlrc.HEAD		\
			pb$pp.$subj.r04.$pb+tlrc.HEAD		\
			pb$pp.$subj.r05.$pb+tlrc.HEAD		\
		-mask full_mask.$subj+tlrc.HEAD			\
		-censor motion_$subj.r02_05.censor.1D	\
		-cenmode ZERO							\
		-ort motion_demean.$subj.r02_05.1D		\
		-prefix $pname
fi
