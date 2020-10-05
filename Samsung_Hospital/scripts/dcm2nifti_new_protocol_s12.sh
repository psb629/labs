#!/bin/tcsh
## This script was written to convert dcm files into NIFTI files by Sungbeen Park

# ex) The raw data in S12_200922 directory
set subj = S12
set date = 200922
set root_dir = /Users/clmn/Desktop/Samsung_Hospital

set subj_dir = $root_dir/${subj}_${date}_MRI
set output_dir = $root_dir/preproc_data/$subj
#########################################################
# T1 data : 366 files
#########################################################
set raw_T1 = $subj_dir/${subj}_${date}_t1
dcm2niix_afni -o $output_dir -s y -z y -f "${subj}_T1" $raw_T1
#########################################################
# fMRI data : 18001 files
#########################################################
set raw_fMRI = $subj_dir/${subj}_${date}_fMRI
mkdir -m 777 $output_dir

set TR = 2

set cnt = 0
set set_time = `count -digit 1 1 300`
foreach t_ini ($set_time)
	set set_data = `count -digit 4 $t_ini 18001 300`
	foreach n ($set_data)
		@ cnt = $cnt + 1
		set n_prime = `printf %05d $cnt`
		cp $raw_fMRI/$subj.dcm$n.dcm $output_dir/temp$n_prime.dcm
	end
	set t = `printf %03d $t_ini`
	dcm2niix_afni -o $output_dir -s y -z y -f "${subj}_func$t" $output_dir
	rm $output_dir/*.dcm
end
mkdir -m 777 $output_dir/preprocessed
3dTcat -tr $TR -prefix $output_dir/preprocessed/pb00.$subj.tcat $output_dir/*.nii.gz
rm $output_dir/${subj}_func*.nii.gz
3dAFNItoNIFTI -prefix $output_dir/${subj}_fMRI.nii.gz $output_dir/pb00.$subj.tcat+orig.
#########################################################
# DTI data : 3221 files
#########################################################
set raw_DTI = $subj_dir/${subj}_${date}_dti
#########################################################
rm $output_dir/*.json
