#!/bin/zsh

dir_root=/mnt/sdb2/GL/fmri_data/stats/GLM.reward

list_=(`find $dir_root -type d -name "GL??"`)
##===========================================##
roi="striatum"
 #roi="caudate"
foreach dir ($list_)
	subj=$dir[-4,-1]
	3dresample -master $dir_root/$subj/full_mask.$subj+orig.nii  \
			-input $dir_root/$subj/$subj.$roi.1mm.orig.nii \
			-prefix $dir_root/$subj/$subj.$roi.orig.nii
end
