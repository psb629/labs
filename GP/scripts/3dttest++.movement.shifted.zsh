#!/bin/zsh

list_cTBS=( \
	09 10 18 21 22 24 \
	27 34 35 36 38 42 \
	)
list_m1=( \
	08 11 17 19 20 26 \
	32 33 37 39 40 41
	)
list_20Hz=( \
	43 44 45 46 47 48 \
	49 50 51 53 54 55
	)

dir_root="/mnt/ext6/GP/fmri_data"

stat='0s_shifted'
dir_stat=$dir_root/stats/GLM.movement.$stat
dir_output=$dir_stat

## DLPFC (cTBS)
setA=()
foreach nn ($list_cTBS)
	setA=($setA $dir_stat/GP$nn/stats.GP$nn+tlrc.HEAD'[Length#1_Coef]')
end
cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setA \
	-prefix GP.dlPFC_cTBS.Zscore.n12.nii \
	-toz
 #	-ClustSim 10

## m1 (cTBS)
setB=()
foreach nn ($list_m1)
	setB=($setB $dir_stat/GP$nn/stats.GP$nn+tlrc.HEAD'[Length#1_Coef]')
end
cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setB \
	-prefix GP.m1.Zscore.n12.nii \
	-toz

## DLPFC (20Hz)
setC=()
foreach nn ($list_20Hz)
	setC=($setC $dir_stat/GP$nn/stats.GP$nn+tlrc.HEAD'[Length#1_Coef]')
end
cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setC \
	-prefix GP.dlPFC_20Hz.Zscore.n12.nii \
	-toz

## Two sample t-test
cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setA\
	-setB $setB\
	-prefix GP.dlPFC_cTBS-M1_cTBS.Zscore.nii\
	-toz
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setC\
	-setB $setB\
	-prefix GP.dlPFC_20Hz-M1_cTBS.Zscore.nii\
	-toz
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setC\
	-setB $setA\
	-prefix GP.dlPFC_20Hz-dlPFC_cTBS.Zscore.nii\
	-toz
