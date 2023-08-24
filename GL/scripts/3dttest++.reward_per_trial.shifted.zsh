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
time_shift=`printf "%1d\n" $tt`
## ============================================================ ##
dir_root="/mnt/ext4/GL"
dir_fmri="$dir_root/fmri_data"
dir_stat="$dir_fmri/stats/AM/GLM.reward_per_trial/${time_shift}s_shifted"

dir_output=$dir_stat
## ============================================================ ##
mask="$dir_fmri/masks/mask.group.n24.frac=0.7.nii"
## ============================================================ ##
list_subj=(`ls $dir_stat | grep "GL[0-9][0-9]"`)
## ============================================================ ##
## on/off
cd $dir_stat

setA=()
for subj in $list_subj
	setA=($setA "$subj/on_off/stats.Rew.$subj.on_off.nii[On#1_Coef]")
setB=()
for subj in $list_subj
	setB=($setB "$subj/on_off/stats.Rew.$subj.on_off.nii[Off#1_Coef]")

pname="3dttest++.paired.reward.on-off.n$#list_subj.nii"
if [ ! -f $pname ]; then
	3dttest++		\
		-setA $setA	\
		-setB $setB	\
		-paired		\
		-mask $mask	\
		-ClustSim 6	\
		-prefix $pname
fi
## ============================================================ ##
cd $dir_stat

setC=()
for cond in 'main' 'test'
{
	for subj in $list_subj
	{
		setC=($setC "$subj/$cond/stats.Rew.$subj.$cond.nii[Rew#1_Coef]")
	}

	pname="3dttest++.reward.$cond.n$#list_subj.nii"
	if [ ! -f $pname ]; then
		3dttest++		\
			-setA $setC	\
			-mask $mask	\
			-ClustSim 6	\
			-prefix $pname
	fi
}
## ============================================================ ##
