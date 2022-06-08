#!/bin/zsh

dir_root=/mnt/sdb2/GL/fmri_data/stats/GLM.reward

list_subj=(`ls $dir_root | grep GL`)
##===========================================##
foreach subj ($list_subj)
	3dcalc -a $dir_root/$subj/$subj.striatum.nii -b $dir_root/$subj/full_mask.$subj+orig.nii \
		-expr 'ispositive(b-a)' -prefix $dir_root/$subj/$subj.reverse.striatum.orig.nii
end
