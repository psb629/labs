#!/bin/zsh

list_nn=(03 04 05 06 07 \
		08 09 10 11 12 \
		14 15 16 17 18 \
		19 20 21 22 24 \
		25 26 27 29)

dir_root=/mnt/ext6/GL/fmri_data

stat='2s_shifted'
dir_stat=$dir_root/stats/GLM.reward.$stat.SSKim
dir_output=$dir_stat

 #setA=()
 #setB=()
 #foreach nn ($list_nn)
 #	setA=($setA $dir_stat/GL$nn/stats.GL$nn+tlrc.HEAD'[RewFB#1_Coef]')
 #	setB=($setB $dir_stat/GL$nn/stats.GL$nn+tlrc.HEAD'[RewnFB#1_Coef]')
 #end
 #3dttest++ -mask $dir_root/masks/full_mask.GL+tlrc.nii \
 #	-setA $setA	-setB $setB -paired \
 #	-prefix $dir_output/tmp

setA=()
foreach nn ($list_nn) 
	setA=($setA $dir_stat/GL$nn/stats.GL$nn+tlrc.HEAD'[Rew#1_Coef]')
end

cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GL+tlrc.nii\
	-setA $setA \
	-prefix GL.group.Zscore.n24.nii \
	-ClustSim 10
 #	-toz

