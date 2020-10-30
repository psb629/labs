#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

set fmri_dir = /Volumes/clmnlab/GL/fmri_data

foreach subj ($subj_list)
	set output_dir = /Volumes/T7SSD1/GL/fMRI_data/GL$subj
	if ( ! -d $output_dir ) then
		mkdir $output_dir
	endif
	cp $fmri_dir/GL$subj/preprocessed/pb04.GL$subj.r??.scale+tlrc.* $output_dir/
end
