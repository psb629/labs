#!/bin/tcsh

set subj = S22_210121

set root_dir = /Users/clmn/Desktop/Samsung_Hospital/fmri_data/raw_data/first_scan/${subj}_MRI
set output_dir = ~/Desktop/test

if (! -d $output_dir) then
	mkdir -p -m 755 $output_dir
endif

cd $root_dir/${subj}_T1
dcm2niix_afni -o $output_dir -s y -z y -f "${subj}_T1" $root_dir/${subj}_T1
 #Dimon -infile_pat '*.dcm' -gert_create_dataset -gert_to3d_prefix temp \
 #	-gert_outdir $output_dir -gert_quit_on_err
