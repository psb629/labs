#!/bin/zsh

## ============================================================ ##
list_nn=( 08 09 10 11 17 \
		  18 19 20 21 22 \
		  24 26 27 32 33 \
		  34 35 36 37 38 \
		  39 40 41 42 43 \
		  44 45 46 47 48 \
		  49 50 51 53 54 \
		  55 56 57 58 59 \
	  	  61 62 )
## ============================================================ ##
dir_root="/mnt/ext5/GP/fmri_data"
dir_mask="$dir_root/masks"

dir_stat="$dir_root/stats/GLM.move-stop"
dir_output=$dir_stat
## ============================================================ ##
mask="$dir_mask/mask.group.day1.n42.frac=0.7.nii"
## ============================================================ ##
setA=()
for nn in $list_nn
{
	subj="GP$nn"
	setA=($setA $dir_stat/$subj/stat.move-stop.$subj.nii'[Move-Stop_GLT#0_Coef]')
}

cd $dir_output
3dttest++ -mask $mask								\
	-setA $setA										\
	-prefix GP.group.move-stop.n$#list_nn.nii		\
	-ClustSim 4
