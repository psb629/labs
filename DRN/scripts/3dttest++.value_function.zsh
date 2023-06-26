#!/bin/zsh

## ============================================================ ##
## default
tt=0
## ============================================================ ##
while (( $# )); do
	key="$1"
	case $key in
		-t | --time_shift)
			tt="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
time_shift=`printf "%1.1f" $tt`
## ============================================================ ##
dir_root="/mnt/ext5/DRN"
dir_fmri="$dir_root/fmri_data"
dir_stat="$dir_fmri/stats/GLM/AM/value_function/shift=${time_shift}s"
## ============================================================ ##
mask=`find $dir_fmri/masks -type f -name "mask.group.n*.frac=0.7.nii"`
## ============================================================ ##
cd $dir_stat

setA=()
list_fname=(`find DRN?? -type f -name "stats.DRN??.nii"`)
for fname in $list_fname
{
	setA=($setA "${fname}[Val#1_Coef]")
}
## ============================================================ ##
cd $dir_stat
3dttest++		\
	-setA $setA	\
	-mask $mask	\
	-prefix "3dttest++.Val#1_Coef.n$#list_fname.nii"
