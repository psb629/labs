#!/bin/zsh

list_nn=(03 04 05 06 07 \
		08 09 10 11 12 \
		14 15 16 17 18 \
		19 20 21 22 24 \
		25 26 27 29)
dir_root=/mnt/ext6/GL/fmri_data/masks
dir_atlas=/mnt/sda2/atlas
##===========================================##
## caudate (L): 11
## caudate (R): 50
## striatum (L): 12
## striatum (R): 51
## individual striatums
 #foreach nn ($list_nn)
 #	subj="GL$nn"
 #	## FreeSurfer
 #	dir_output=$dir_root/FreeSurfer
 #	if [ ! -d $dir_output ]; then
 #		mkdir -p -m 755 $dir_output
 #	fi
 #	data=$dir_root/FreeSurfer/$subj.aparc+aseg.nii
 #	3dcalc -a $data -expr 'or(equals(a,11),equals(a,50))'\
 #		-prefix $dir_output/$subj.caudate.1mm.orig.nii
 #	3dcalc -a $data -expr 'or(equals(a,12),equals(a,51))'\
 #		-prefix $dir_output/$subj.putamen.1mm.orig.nii
 #	3dcalc -a $data -expr 'or(equals(a,26),equals(a,58))'\
 #		-prefix $dir_output/$subj.NAc.1mm.orig.nii
 #	3dcalc -a $data -expr 'or(equals(a,11),equals(a,50),equals(a,12),equals(a,51),equals(a,26),equals(a,58))'\
 #		-prefix $dir_output/$subj.striatum.1mm.orig.nii
 #end
 #
 ### Harvard-Oxford
 #3dcalc -a $dir_atlas/HarvardOxford/HarvardOxford-sub-maxprob-thr0-1mm.nii.gz -expr 'or(equals(a,6),equals(a,17))' \
 #	-prefix $dir_root/HarvardOxford-sub-maxprob-thr0-1mm.putamen.nii
 #
 #3dcalc -a $dir_atlas/HarvardOxford/HarvardOxford-sub-maxprob-thr0-1mm.nii.gz -expr 'or(equals(a,5),equals(a,16))' \
 #	-prefix $dir_root/HarvardOxford-sub-maxprob-thr0-1mm.caudate.nii
 #
 #3dcalc -a $dir_atlas/HarvardOxford/HarvardOxford-sub-maxprob-thr0-1mm.nii.gz -expr 'or(equals(a,11),equals(a,21))' \
 #	-prefix $dir_root/HarvardOxford-sub-maxprob-thr0-1mm.NAc.nii

## TT_Daemon
### Left caudate Head 326
### Left caudate Body 325
### Right caudate Head 126
### Right caudate Body 125
3dresample -prefix $dir_root/resam.TTatlas.nii -input $dir_atlas/afni/TTatlas.nii -master $dir_root/full_mask.GL+tlrc.nii
3dcalc -a $dir_root/resam.TTatlas.nii'[uu5[0]]' -expr 'equals(a,326) + equals(a,325)*2 + equals(a,126)*3 + equals(a,125)*4' \
	-prefix $dir_root/mask.caudate.nii
