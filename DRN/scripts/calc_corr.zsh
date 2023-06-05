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
		-r | --run)
			run="$2"
		;;
		-h | --help)
			echo "-s, --subject\n\t-s DRN04"
			echo "-l, --layer\n\t-l conv1"
			echo "-r, --run\n\t-r r01"
			exit
		;;
	esac
	shift ##takes one argument
done
## ===================================== ##
dir_work=/mnt/ext5/DRN/fmri_data/encoding_model/$subj
## ===================================== ##
3dTcorrelate	\
	-pearson	\
	-prefix $dir_work/corr3D.$run.$layer.nii	\
	$dir_work/Y.$run.nii	\
	$dir_work/Y_pred.$run.$layer.nii
