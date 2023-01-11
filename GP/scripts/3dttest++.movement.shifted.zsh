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
	57 59 62		  \
	)
list_m1=( \
	08 11 17 19 20 26 \
	32 33 37 39 40 41 \
	56 58 61		  \
	)
list_20=( \
	43 44 45 46 47 48 \
	49 50 51 53 54 55 \
	)
## ============================================================ ##
dir_root="/mnt/ext5/GP"
stat="${time_shift}s_shifted"

dir_fmri="$dir_root/fmri_data"
dir_mask="$dir_fmri/masks"
dir_stat="$dir_fmri/stats/AM/GLM.movement/$stat"

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
	setA=($setA $dir_stat/$subj/stats.Cursor.$subj+tlrc.HEAD'[Cursor#1_Coef]')
}
3dttest++ -mask $mask							\
	-setA $setA									\
	-prefix GP.dlPFC.Zscore.n$#list_dlpfc.nii	\
	-toz
 #	-ClustSim 10

## m1
setB=()
for nn in $list_m1
{
	subj="GP$nn"
	setB=($setB $dir_stat/$subj/stats.Cursor.$subj+tlrc.HEAD'[Cursor#1_Coef]')
}
3dttest++ -mask $mask					\
	-setA $setB							\
	-prefix GP.m1.Zscore.n$#list_m1.nii	\
	-toz

## DLPFC (20Hz)
setC=()
for nn in $list_20
{
	subj="GP$nn"
	setC=($setC $dir_stat/$subj/stats.Cursor.$subj+tlrc.HEAD'[Cursor#1_Coef]')
}
cd $dir_output
3dttest++ -mask $mask							\
	-setA $setC									\
	-prefix GP.dlPfc_20.Zscore.n$#list_20.nii	\
	-toz
## ============================================================ ##
## Two sample t-test
3dttest++ -mask $mask							\
	-setA $setA									\
	-setB $setB									\
	-prefix GP.dlPFC_cTBS-M1_cTBS.Zscore.nii	\
	-toz
3dttest++ -mask $mask							\
	-setA $setC									\
	-setB $setB									\
	-prefix GP.dlPFC_20Hz-M1_cTBS.Zscore.nii	\
	-toz
3dttest++ -mask $mask							\
	-setA $setC									\
	-setB $setA									\
	-prefix GP.dlPFC_20Hz-dlPFC_cTBS.Zscore.nii	\
	-toz
