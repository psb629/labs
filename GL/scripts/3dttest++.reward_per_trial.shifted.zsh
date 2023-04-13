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
time_shift=`printf "%.1f\n" $tt`
## ============================================================ ##
dir_behav="/home/sungbeenpark/Github/labs/GL/behav_data"
dir_reg="$dir_behav/regressors/AM"

dir_root="/mnt/ext4/GL"
dir_fmri="$dir_root/fmri_data"
dir_stat="$dir_fmri/stats/AM/GLM.reward_per_trial/${time_shift}s_shifted"
## ============================================================ ##
mask="$dir_fmri/masks/mask.group.n24.frac=0.7.nii"
## ============================================================ ##
list_subj=(`ls $dir_stat | grep "GL[0-9][0-9]"`)
## ============================================================ ##
cd $dir_stat

setA=()
for subj in $list_subj
	setA=($setA "$subj/On/stats.Rew.$subj.On.nii[Rew#1_Coef]")
setB=()
for subj in $list_subj
	setB=($setB "$subj/Off/stats.Rew.$subj.Off.nii[Rew#1_Coef]")

3dttest++		\
	-setA $setA	\
	-setB $setB	\
	-paired		\
	-mask $mask	\
	-ClustSim 6	\
	-prefix "3dttest++.paired.reward.On-Off.n$#list_subj.nii"
## ============================================================ ##
cd $dir_stat

setC=()
for subj in $list_subj
	setC=($setC "$subj/Test/stats.Rew.$subj.Test.nii[Rew#1_Coef]")

3dttest++		\
	-setA $setC	\
	-mask $mask	\
	-ClustSim 6	\
	-prefix "3dttest++.reward.Test.n$#list_subj.nii"
