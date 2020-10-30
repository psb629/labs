#!/bin/tcsh

set subj_list = (01 02 07 11 15 20 23 26 29 30 31 32 33 44)

set root_dir = /Volumes/T7SSD1/GD/fMRI_data/preproc_data

foreach subj ($subj_list)
	cd $root_dir/GD$subj/preprocessed
	mv ./pb02.GD$subj.r??.*+tlrc.* /Users/clmn/Desktop/GD/fMRI_data/pb02/
	mv ./pb03.GD$subj.r??.*+tlrc.* /Users/clmn/Desktop/GD/fMRI_data/pb03/
end
