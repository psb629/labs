#!/bin/tcsh


set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15 GD38)

set from_dir = /Volumes/clmnlab/GD
set to_dir = /Volumes/WD_HDD1/GD

if ( ! -d $to_dir ) then
	mkdir -m 755 $to_dir
endif

foreach subj ($subj_list)
	echo "processing $subj..."
	## behav_data
	set output_dir = $to_dir/behav_data
 #	if ( ! -d $output_dir ) then
 #		mkdir -p -m 755 $output_dir
 #	endif
 #	cp $from_dir/behav_data/$subj-refmri.mat $output_dir
	## raw dicom
	set output_dir = $to_dir/fmri_data/raw_data/$subj
	if ( ! -d $output_dir ) then
		mkdir -p -m 755 $output_dir
	endif
	cp -r $from_dir/fMRI_data/raw_data/$subj/* $output_dir
	## raw fmri_data
end
