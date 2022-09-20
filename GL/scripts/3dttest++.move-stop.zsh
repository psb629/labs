#!/bin/zsh

list_nn=(03 04 05 06 07 \
		08 09 10 11 12 \
		14 15 16 17 18 \
		19 20 21 22 24 \
		25 26 27 29)

dir_root=/mnt/ext6/GL/fmri_data
dir_stat=$dir_root/stats/GLM.Move-Stop.SSKim
dir_output=$dir_stat

setA=()
foreach nn ($list_nn) 
	subj=GL$nn
	## source: me
 #	setA=($setA $dir_stat/statMove.${subj}+tlrc.HEAD'[Move-Stop_GLT#0_Coef]')
	## source: Sungshin Kim
	setA=($setA $dir_stat/$subj/statMove.${subj}+tlrc.HEAD'[Move-Stop_GLT#0_Coef]')
end

cd $dir_output
3dttest++ -mask $dir_root/masks/full_mask.GL+tlrc.nii\
	-setA $setA \
	-prefix GL.group.Zscore.n24.nii \
	-ClustSim 10
 #	-toz
