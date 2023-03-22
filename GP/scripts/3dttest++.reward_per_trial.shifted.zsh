#!/bin/zsh

## ============================================================ ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
		-t | --time_shift)
			tt="$2"
		;;
		-r | --run)
			run="$2"
		;;
		-g | --group)
			group="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
if [ ! $tt ]; then
	tt=0
fi
time_shift=`printf "%.1f\n" $tt`
## ============================================================ ##
case $group in
	'dlpfc_cTBS' | 'dlPFC_cTBS' | 'DLPFC_cTBS')
		group='DLPFC_cTBS'
		list_nn=(
			09 10 18 21 22 24 \
			27 34 35 36 38 42 \
			57 59 62 66 67	  \
		)
	;;
	'm1_cTBS' | 'M1_cTBS')
		group='M1_cTBS'
		list_nn=(
			08 11 17 19 20 26 \
			32 33 37 39 40 41 \
			56 58 61 63 65	  \
		)
	;;
	'dlpfc_20Hz' | 'dlPFC_20Hz' | 'DLPFC_20Hz')
		group='DLPFC_20Hz'
		## GP50은 GP26과 동일인물
		list_nn=(
			43 44 45 46 47 48 \
			49 51 53 54 55 \
		)
	;;
	*)
		group=false
	;;
esac
if [ $group = false ]; then
	print " You need to put the right value for -g"
	print " e.g.) -g DLPFC_cTBS"
	exit
fi
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
dir_root="/mnt/ext5/GP"
stat="${time_shift}s_shifted"

dir_fmri="$dir_root/fmri_data"
dir_mask="$dir_fmri/masks"
dir_stat="$dir_fmri/stats/AM/GLM.reward_per_trial/$stat"

dir_output=$dir_stat
## ============================================================ ##
mask="$dir_mask/mask.group.day2.n42.frac=0.7.nii"
## ============================================================ ##
## one sample t-test
setA=()
for nn in $list_nn
{
	subj="GP$nn"
	setA=($setA "$dir_stat/$subj/stats.Rew.$subj.$run.nii[Rew#1_Coef]")
}
pname="$dir_output/$run.$group.n$#list_nn.nii"
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
	pname="$dir_output/$prop.$run.$group.n$#list_nn.nii"
	3dcalc -a "${fname}[SetA_$pp]" -expr 'a' -prefix $pname
	if [ $pp = 'Tstat' ]; then
		dof=`3dinfo -verb $pname | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
		TtoZ --t_stat_map=$pname --dof=$dof \
			--output_nii="$dir_output/Zstat.$run.$group.n$#list_nn.nii"
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
