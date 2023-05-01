#!/bin/zsh

##############################################################
## default
radius=3
ROI=false
##############################################################
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-r | --radius)
			radius="$2"
		;;
		;;
		-R | --ROI)
			ROI="$2"
		;;
	esac
	shift ##takes one argument
done
##############################################################
dir_root="/mnt/ext5/SMC/fmri_data"
dir_mask="$dir_root/masks"

dir_output=$dir_mask
##############################################################
xyz="$dir_mask/3dUndump.$ROI.mean.xyz.1D"
if [ ! -f $xyz ]; then
	exit
fi
mask=`find $dir_mask -type f -name "mask.group.n*.frac=0.7.nii"`
 #pname="$dir_mask/resampled.MNI152_2009_template_SSW.nii"
 #if [ ! -f $pname ]; then
 #	3dresample															\
 #		-master $mask													\
 #		-input "/usr/local/afni/abin/MNI152_2009_template_SSW.nii.gz"	\
 #		-prefix $pname
 #fi
3dUndump 												\
	-prefix "$dir_output/3dUndump.$ROI.r=$radius.nii"	\
	-master $mask										\
	-mask $mask											\
	-srad $radius										\
	-xyz $xyz
