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
dir_stat="$dir_fmri/stats/AM/GLM.cursor_length_per_trial/${time_shift}s_shifted"

dir_output=$dir_stat
## ============================================================ ##
mask="$dir_fmri/masks/mask.group.n24.frac=0.7.nii"
## ============================================================ ##
list_subj=(`ls $dir_stat | grep "GL[0-9][0-9]"`)
## ============================================================ ##
## on - off
cd $dir_stat

setA=()
for subj in $list_subj
	setA=($setA "$subj/on/stats.Len.$subj.on.nii[Len#1_Coef]")
setB=()
for subj in $list_subj
	setB=($setB "$subj/off/stats.Len.$subj.off.nii[Len#1_Coef]")

pname="3dttest++.paired.cursor_length.on-off.n$#list_subj.nii"
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
		setC=($setC "$subj/$cond/stats.Len.$subj.$cond.nii[Len#1_Coef]")
	}

	pname="3dttest++.cursor_length.$cond.n$#list_subj.nii"
	if [ ! -f $pname ]; then
		3dttest++		\
			-setA $setC	\
			-mask $mask	\
			-ClustSim 6	\
			-prefix $pname
	fi
}
## ============================================================ ##
