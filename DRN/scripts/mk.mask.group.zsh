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
dir_root="/mnt/ext5/DRN/fmri_data"
dir_preproc="$dir_root/preproc_data"
dir_mask="$dir_root/masks"
##############################################################
## generate 'frac' group mask and related (or intersection mask)
cd $dir_preproc
list_fname=(`find DRN?? -type f -name "full_mask.*.HEAD"`)
pname="$dir_mask/mask.group.n$#list_fname.frac=$frac.nii"
rm $pname
3dmask_tool				\
	-input $list_fname	\
	-prefix	$pname		\
	-frac $frac
