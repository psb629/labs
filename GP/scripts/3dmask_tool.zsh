#!/bin/zsh

##############################################################
## default
frac=0.7
##############################################################
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-f | --frac)
			frac="$2"
		;;
		-d | --day)
			dd="$2"
		;;
	esac
	shift ##takes one argument
done
day="day$dd"
##############################################################
dir_root="/mnt/ext5/GP/fmri_data"
dir_preproc="$dir_root/preproc_data"
dir_mask="$dir_root/masks"

dir_output=$dir_mask
##############################################################
## generate 'frac' group mask and related (or intersection mask)
cd $dir_preproc
list_fname=(`find GP??/$day -type f -name "full_mask.*.HEAD"`)
3dmask_tool																\
	-input $list_fname													\
	-prefix	"$dir_output/mask.group.$day.n$#list_fname.frac=$frac.nii"	\
	-frac $frac
