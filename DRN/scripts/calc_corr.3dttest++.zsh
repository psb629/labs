#!/bin/zsh

## ===================================== ##
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
		-l | --layer)
			layer="$2"
		;;
		-p | --process)
			pb="$2"
		;;
		-h | --help)
			echo "-s, --subject\n\t-s DRN04"
			echo "-l, --layer\n\t-l conv1"
			echo "-p, --process\n\t-p scale"
			exit
		;;
	esac
	shift ##takes one argument
done
## ===================================== ##
dir_work=/mnt/ext5/DRN/fmri_data/encoding_model/$subj
## ===================================== ##
cd $dir_work
3dttest++		\
	-setA $dir_work/corr3D.$pb.r0?.$layer.nii	\
	-prefix $dir_work/corr3D.3dttest++.$pb.$layer.nii
