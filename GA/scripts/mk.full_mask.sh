#!/bin/tcsh

set ii_list = ( GA GB )
set nn_list = ( 01 02 05 07 08 \
				11 12 13 14 15 \
				18 19 20 21 23 \
				26 27 28 29 30 \
				31 32 33 34 35 \
				36 37 38 42 44 )

set from_dir = /Volumes/clmnlab/GA/fmri_data/preproc_data
set to_dir = /Volumes/T7SSD1/GA/fMRI_data/roi/full
 #set to_dir = /Volumes/T7SSD1/WinterCamp2021/masks/full
if (! -d $to_dir) then
	mkdir -p -m 755 $to_dir
endif

foreach ii ($ii_list)
	foreach nn ($nn_list)
		set subj = $ii$nn
		set to = $to_dir/full_mask.$subj.nii.gz
		if (! -e $to) then
			3dAFNItoNIFTI -prefix $to $from_dir/$subj/full_mask.$subj+tlrc
		endif
	end
end
