#!/bin/zsh

## ============================================================ ##
## default
time_shift=0
## ============================================================ ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-t | --time_shift)
			## string
			time_shift="$2"
		;;
	esac
	shift ##takes one argument
done
tmp=`printf "%.1f\n" $time_shift`
time_shift=$tmp
stat="${time_shift}s_shifted"
## ============================================================ ##
dir_root="/mnt/ext5/GA"

dir_fmri="$dir_root/fmri_data"
dir_mask="$dir_fmri/masks"
dir_stat="$dir_fmri/stats/AM/GLM.reward_per_trial/$stat"

dir_output=$dir_stat
## ============================================================ ##
list_subj=(`ls $dir_stat | grep "G.[0-9][0-9]"`)
## ============================================================ ##
mask="$dir_mask/mask.group.GA.n30.frac=0.7.nii"
## ============================================================ ##
cd $dir_output

setA=()
for subj in $list_subj
{
	setA=($setA $dir_stat/$subj/stats.Rew.$subj.nii'[Rew#1_Coef]')
}
3dttest++ -mask $mask							\
	-setA $setA									\
	-prefix group.Clustsim.n$#list_subj.nii	\
	-ClustSim 4
## ============================================================ ##
## extract the Z stat
3dcalc -a group.Clustsim.n$#list_subj.nii'[SetA_Zscr]' -expr 'a' -prefix group.Zscr.n$#list_subj.nii
