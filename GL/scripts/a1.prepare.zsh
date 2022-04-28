#!/bin/zsh

list_nn=(03 04 05 06 07 \
		08 09 10 11 12 \
		14 15 16 17 18 \
		19 20 21 22 24 \
		25 26 27 29)
##===========================================##
dir_root=/mnt/sda2/GL/fmri_data/ROC_curve
##===========================================##
dir_t1_orig=/mnt/sda2/GL/fmri_data
dir_t1_label=/home/kjh/GL/GL_subjects/parseg_nii
 #foreach nn ($list_nn)
 #	subj="GL$nn"
 #
 #	dir_output=$dir_root/$subj
 #	if [ ! -d $dir_output ]; then
 #		mkdir -p -m 755 $dir_output
 #	fi
 #
 #	from=$dir_t1_orig/$subj/$subj.anat.nii
 #	if [ ! -f $from ]; then
 #		3dAFNItoNIFTI -prefix $from $dir_t1_orig/$subj/$subj.MPRAGE+orig
 #	fi
 #	to=$dir_output/$subj.anat.nii
 #	cp -n $from $to
 #
 #	from=$dir_t1_label/${subj}_aparc+aseg.nii
 #	to=$dir_output/$subj.aparc+aseg.nii
 #	cp -n $from $to
 #end
##===========================================##
foreach nn ($list_nn)
	dir_output=/mnt/sdb2/GL/fmri_data/preproc_data/GL$nn/stimuli
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi
end
