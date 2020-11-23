#!/bin/tcsh


set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
set from_dir = /Volumes/clmnlab/GA
set to_dir = /Volumes/WD_HDD1/GA

if ( ! -d $to_dir ) then
	mkdir -m 755 $to_dir
endif

## behav_data
set output_dir = $to_dir/behav_data
if ( ! -d $output_dir ) then
	mkdir -m 755 $output_dir
endif
cp -r $from_dir/behav_data $output_dir

 #foreach id (GA GB)
 #	foreach ss ($subj_list)
 #		echo "processing $subj..."
 #		## raw dicom
 #		set output_dir = $to_dir/fmri_data/raw_data/$subj
 #		if ( ! -d $output_dir ) then
 #			mkdir -p -m 755 $output_dir
 #		endif
 #		cp -r $from_dir/fMRI_data/raw_data/$subj/* $output_dir
 #		## basic preprocessed-fmri_data
 #		set output_dir = $to_dir/fmri_data/preproc_data/$subj
 #		if ( ! -d $output_dir ) then
 #			mkdir -p -m 755 $output_dir
 #		endif
 #		cp $from_dir/fMRI_data/preproc_data/$subj/*+orig.* $output_dir
 #	end
 #end
