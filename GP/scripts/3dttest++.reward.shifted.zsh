#!/bin/zsh

 #list_subj=( 08 09 10 11 17 \
 #			18 19 20 21 22 \
 #			24 26 27 32 33 \
 #			34 35 36 37 38 \
 #			39 40 41 42 43 \
 #			44 45 46 47 48 \
 #			49 50 51 53 54 \
 #			55 )
list_low=( \
	09 10 18 21 22 24 \
	27 34 35 36 38 42 \
	)
list_m1=( \
	08 11 17 19 20 26 \
	32 33 37 39 40 41
	)
list_high=( \
	43 44 45 46 47 48 \
	49 50 51 53 54 55
	)

dir_root="/mnt/ext6/GP/fmri_data"

stat='5s_shifted'
dir_stat=$dir_root/stats/GLM.reward.$stat
dir_output=$dir_stat

## DLPFC (low)
 #dir_output=$dir_stat/DLPFC_low
 #if [ ! -d $dir_output ]; then
 #	mkdir -p -m 755 $dir_output
 #fi
setA=()
foreach nn ($list_low)
	setA=($setA $dir_stat/GP$nn/stats.GP$nn+tlrc.HEAD'[Rew#1_Coef]')
end
cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setA \
	-prefix GP.dlPFC_low.Zscore.n12.nii \
	-toz
 #	-ClustSim 10

## m1
 #dir_output=$dir_stat/m1
 #if [ ! -d $dir_output ]; then
 #	mkdir -p -m 755 $dir_output
 #fi
setB=()
foreach nn ($list_m1)
	setB=($setB $dir_stat/GP$nn/stats.GP$nn+tlrc.HEAD'[Rew#1_Coef]')
end
cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setB \
	-prefix GP.m1.Zscore.n12.nii \
	-toz

## DLPFC (high)
 #dir_output=$dir_stat/DLPFC_high
 #if [ ! -d $dir_output ]; then
 #	mkdir -p -m 755 $dir_output
 #fi
setC=()
foreach nn ($list_high)
	setC=($setC $dir_stat/GP$nn/stats.GP$nn+tlrc.HEAD'[Rew#1_Coef]')
end
cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GP.group.nii\
	-setA $setC \
	-prefix GP.dlPFC_high.Zscore.n12.nii \
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
