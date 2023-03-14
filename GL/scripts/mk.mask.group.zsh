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
dir_root="/mnt/ext4/GL/fmri_data"
dir_preproc="$dir_root/preproc_data.SSKim"
dir_mask="$dir_root/masks"
##############################################################
## generate 'frac' group mask and related (or intersection mask)
cd $dir_preproc
list_fname=(`find GL?? -type f -name "full_mask.*.HEAD"`)
print $list_fname
3dmask_tool														\
	-input $list_fname											\
	-prefix	"$dir_mask/mask.group.n$#list_fname.frac=$frac.nii"	\
	-frac $frac
