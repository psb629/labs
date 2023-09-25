#!/bin/zsh

## ============================================================ ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
		-p | --phase)
			pp=$2
		;;
		-t | --time_shift)
			tt="$2"
		;;
		-r | --run)
			run="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
case $pp in
	'A' | 'GA')
		phase='GA'
	;;
	'B' | 'GB')
		phase='GB'
	;;
esac
 #print $phase
## ============================================================ ##
if [ ! $tt ]; then
	tt=0
fi
tmp=`printf "%.1f\n" $tt`
time_shift="${tmp}s_shifted"
## ============================================================ ##
case $run in
	1 | 'r01')
		run='r01'
	;;
	2 | 'r02')
		run='r02'
	;;
	3 | 'r03')
		run='r03'
	;;
	*)
		run='rall'
	;;
esac
## ============================================================ ##
dir_root="/mnt/ext5/GA"

dir_fmri="$dir_root/fmri_data"
dir_mask="$dir_fmri/masks"
dir_stat="$dir_fmri/stats/AM/GLM.reward_per_trial/$time_shift"

dir_output=$dir_stat
## ============================================================ ##
list_subj=(`ls $dir_stat | grep -o $phase"[0-9][0-9]"`)
 #print $list_subj
## ============================================================ ##
mask="$dir_mask/mask.group.GA.n30.frac=0.7.nii"
## ============================================================ ##
## one sample t-test
setA=()
for subj in $list_subj
{
	setA=($setA "$dir_stat/$subj/stats.Rew.$subj.$run.nii[Rew#1_Coef]")
}
pname="$dir_output/$phase.$run.prac.n$#list_subj.nii"
3dttest++ -mask $mask	\
	-setA $setA			\
	-prefix $pname
 #	-toz
 #	-ClustSim 10
## ============================================================ ##
fname=$pname
for pp in 'mean' 'Tstat'
{
	prop=$pp
	if [ $pp = 'mean' ]; then
		prop='Coef'
	fi
	pname="$dir_output/$phase.$prop.$run.prac.n$#list_subj.nii"
	3dcalc -a "${fname}[SetA_$pp]" -expr 'a' -prefix $pname
	if [ $pp = 'Tstat' ]; then
		dof=`3dinfo -verb $pname | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
		TtoZ --t_stat_map=$pname --dof=$dof \
			--output_nii="$dir_output/$phase.Zstat.$run.prac.n$#list_subj.nii"
	fi
}
## ============================================================ ##
 ### Two sample t-test
 #3dttest++ -mask $mask					\
 #	-setA $setA							\
 #	-setB $setB							\
 #	-prefix dlPFC_cTBS-M1_cTBS.nii		\
 # #	-toz
 #3dttest++ -mask $mask					\
 #	-setA $setC							\
 #	-setB $setB							\
 #	-prefix dlPFC_20Hz-M1_cTBS.nii		\
 # #	-toz
 #3dttest++ -mask $mask					\
 #	-setA $setC							\
 #	-setB $setA							\
 #	-prefix dlPFC_20Hz-dlPFC_cTBS.nii	\
 # #	-toz
