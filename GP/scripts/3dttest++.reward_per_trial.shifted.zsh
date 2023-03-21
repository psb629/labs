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
## ============================================================ ##
list_dlpfc=( \
	09 10 18 21 22 24 \
	27 34 35 36 38 42 \
	57 59 62 66 67	  \
	)
list_m1=( \
	08 11 17 19 20 26 \
	32 33 37 39 40 41 \
	56 58 61 63 65	  \
	)
## GP50은 GP27과 동일인물
list_20=( \
	43 44 45 46 47 48 \
	49 51 53 54 55 \
	)
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
cd $dir_output

## DLPFC (dlpfc)
setA=()
for nn in $list_dlpfc
{
	subj="GP$nn"
	setA=($setA $dir_stat/$subj/stats.Rew.$subj.nii'[Rew#1_Coef]')
}
3dttest++ -mask $mask						\
	-setA $setA								\
	-prefix dlPFC_cTBS.n$#list_dlpfc.nii
 #	-toz
 #	-ClustSim 10

## m1
setB=()
for nn in $list_m1
{
	subj="GP$nn"
	setB=($setB $dir_stat/$subj/stats.Rew.$subj.nii'[Rew#1_Coef]')
}
3dttest++ -mask $mask					\
	-setA $setB							\
	-prefix M1_cTBS.n$#list_m1.nii
 #	-toz

## DLPFC (20Hz)
setC=()
for nn in $list_20
{
	subj="GP$nn"
	setC=($setC $dir_stat/$subj/stats.Rew.$subj.nii'[Rew#1_Coef]')
}
cd $dir_output
3dttest++ -mask $mask					\
	-setA $setC							\
	-prefix dlPFC_20Hz.n$#list_20.nii
 #	-toz
## ============================================================ ##
## extract the t stat
pname=$dir_output/"dlPFC_cTBS.Tstat.n$#list_dlpfc.nii"
3dcalc -a dlPFC_cTBS.n$#list_dlpfc.nii'[SetA_Tstat]' -expr 'a' -prefix $pname
dof=`3dinfo -verb $pname | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
TtoZ --t_stat_map=$pname --dof=$dof --output_nii=$dir_output/"dlPFC_cTBS.Zscr.n$#list_dlpfc.nii"

pname="$dir_output/M1_cTBS.Tstat.n$#list_m1.nii"
3dcalc -a M1_cTBS.n$#list_m1.nii'[SetA_Tstat]' -expr 'a' -prefix $pname
dof=`3dinfo -verb $pname | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
TtoZ --t_stat_map=$pname --dof=$dof --output_nii=$dir_output/"M1_cTBS.Zscr.n$#list_m1.nii"

pname=$dir_output/"dlPFC_20Hz.Tstat.n$#list_20.nii"
3dcalc -a dlPFC_20Hz.n$#list_20.nii'[SetA_Tstat]' -expr 'a' -prefix $pname
dof=`3dinfo -verb $pname | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
TtoZ --t_stat_map=$pname --dof=$dof --output_nii=$dir_output/"dlPFC_20Hz.Zscr.n$#list_20.nii"

## ============================================================ ##
## extract the mean beta
3dcalc -a dlPFC_cTBS.n$#list_dlpfc.nii'[SetA_mean]' -expr 'a' -prefix dlPFC_cTBS.mean.n$#list_dlpfc.nii
3dcalc -a M1_cTBS.n$#list_m1.nii'[SetA_mean]' -expr 'a' -prefix M1_cTBS.mean.n$#list_m1.nii
3dcalc -a dlPFC_20Hz.n$#list_20.nii'[SetA_mean]' -expr 'a' -prefix dlPFC_20Hz.mean.n$#list_20.nii
## ============================================================ ##
## Two sample t-test
3dttest++ -mask $mask					\
	-setA $setA							\
	-setB $setB							\
	-prefix dlPFC_cTBS-M1_cTBS.nii		\
 #	-toz
3dttest++ -mask $mask					\
	-setA $setC							\
	-setB $setB							\
	-prefix dlPFC_20Hz-M1_cTBS.nii		\
 #	-toz
3dttest++ -mask $mask					\
	-setA $setC							\
	-setB $setA							\
	-prefix dlPFC_20Hz-dlPFC_cTBS.nii	\
 #	-toz
