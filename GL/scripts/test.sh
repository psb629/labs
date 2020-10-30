#!/bin/tcsh

set root_dir = /Volumes/T7SSD1/GL
set fmri_dir = $root_dir/fMRI_data
set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

foreach subj ($subj_list)
	3dAFNItoNIFTI 
end
