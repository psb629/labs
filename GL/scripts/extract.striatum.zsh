#!/bin/zsh

list_nn=(03 04 05 06 07 \
		08 09 10 11 12 \
		14 15 16 17 18 \
		19 20 21 22 24 \
		25 26 27 29)
dir_root=/mnt/sdb2/GL/fmri_data/stats/GLM.reward
##===========================================##
## caudate (L): 11
## caudate (R): 50
## striatum (L): 12
## striatum (R): 51
## individual striatums
foreach nn ($list_nn)
	subj="GL$nn"
	dir_output=$dir_root/$subj

	data=$dir_root/$subj/$subj.aparc+aseg.nii
	3dcalc -a $data -expr 'or(equals(a,11),equals(a,12),equals(a,50),equals(a,51))'\
		-prefix $dir_output/$subj.striatum.1mm.orig.nii
	3dcalc -a $data -expr 'or(equals(a,11),equals(a,50))'\
		-prefix $dir_output/$subj.caudate.1mm.orig.nii
end
 ### MNI striatum
 #mni_mask=
 #3dcalc -a $mni -expr 'or(equals(a,),equals(a,),equals(a,),equals(a,))'\
 #	-prefix $dir_root/
