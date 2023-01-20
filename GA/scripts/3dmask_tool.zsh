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
dir_root="/mnt/ext5/GA/fmri_data"
dir_preproc="$dir_root/preproc_data"
dir_mask="$dir_root/masks"

dir_output=$dir_mask
if [[ ! -d $dir_output ]]; then
	mkdir -p -m 755 $dir_output
fi
##############################################################
## generate 'frac' group mask and related (or intersection mask)
### GA
cd $dir_preproc
list_fname=(`find GA?? -type f -name "full_mask.*.HEAD"`)
3dmask_tool																\
	-input $list_fname													\
	-prefix	"$dir_output/mask.group.GA.n$#list_fname.frac=$frac.nii"	\
	-frac $frac
### GB
cd $dir_preproc
list_fname=(`find GB?? -type f -name "full_mask.*.HEAD"`)
3dmask_tool																\
	-input $list_fname													\
	-prefix	"$dir_output/mask.group.GB.n$#list_fname.frac=$frac.nii"	\
	-frac $frac
### GAGB
cd $dir_preproc
list_fname=(`find G?[0-9][0-9] -type f -name "full_mask.*.HEAD"`)
3dmask_tool																\
	-input $list_fname													\
	-prefix	"$dir_output/mask.group.GAGB.n$#list_fname.frac=$frac.nii"	\
	-frac $frac
