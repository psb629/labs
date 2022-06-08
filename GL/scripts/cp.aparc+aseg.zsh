#!/bin/zsh

list_nn=(03 04 05 06 07 \
		08 09 10 11 12 \
		14 15 16 17 18 \
		19 20 21 22 24 \
		25 26 27 29)
##===========================================##
foreach nn ($list_nn)
	subj="GL$nn"

	from=/mnt/sda2/GL/fmri_data/ROC_curve/$subj/$subj.aparc+aseg.nii
	to=/mnt/sdb2/GL/fmri_data/stats/GLM.reward/$subj
	if [ ! -d $to ]; then
		mkdir -p -m 755 $to
	fi
	cp -n $from $to
end
