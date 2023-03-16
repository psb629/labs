#!/bin/zsh

##############################################################
dir_root="/mnt/ext4/GL/fmri_data/masks"
##############################################################
mask_full="$dir_root/mask.group.n24.frac=0.7.nii"
##############################################################
ref_putamen="$dir_root/HarvardOxford-sub-maxprob-thr0-1mm.putamen.nii"
ref_caudate="$dir_root/HarvardOxford-sub-maxprob-thr0-1mm.caudate.nii"
##############################################################
resam_putamen="$dir_root/HarvardOxford-sub-maxprob-thr0-1mm.putamen.resampled.nii"
if [ ! -f $resam_putamen ]; then
	3dresample 				\
		-master $mask_full	\
		-input $ref_putamen	\
		-prefix "$resam_putamen"
fi
resam_caudate="$dir_root/HarvardOxford-sub-maxprob-thr0-1mm.caudate.resampled.nii"
if [ ! -f $resam_caudate ]; then
	3dresample 				\
		-master $mask_full	\
		-input $ref_caudate	\
		-prefix "$resam_caudate"
fi
##############################################################

