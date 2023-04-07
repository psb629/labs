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
	esac
	shift ##takes one argument
done
##############################################################
dir_root="/mnt/ext5/SMC/fmri_data"
dir_preproc="$dir_root/preproc_data"
dir_mask="$dir_root/masks"

dir_output=$dir_mask
##############################################################
## generate 'frac' group mask and related (or intersection mask)
cd $dir_preproc
list_fname=(`find *.anaticor/with_FreeSurfer/S?? -maxdepth 1 -type f -name "full_mask.S??+tlrc.HEAD"`)
3dmask_tool															\
	-input $list_fname												\
	-prefix	"$dir_output/mask.group.n$#list_fname.frac=$frac.nii"	\
	-frac $frac
