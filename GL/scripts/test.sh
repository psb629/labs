#!/bin/tcsh

 #set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
 #
 #set root_dir = /Volumes/clmnlab/GL/fmri_data/
 #set obj_dir = /Volumes/T7SSD1/GL/fMRI_data/
 #
 #foreach cc ($subj_list)
 #	set subj = GL$cc
 #	if ( ! -e $obj_dir/$subj/motion_demean.$subj.r02_05.1D ) then
 #		cp $root_dir/$subj/preprocessed/motion_demean.$subj.r02_05.1D $obj_dir/$subj/
 #	else
 #		echo "motion_demean.$subj.r02_05.1D already exists!"
 #	endif
 #	if ( ! -e $obj_dir/$subj/motion_censor.$subj.r02_05.1D ) then
 #		cp $root_dir/$subj/preprocessed/motion_$subj.r02_05.censor.1D $obj_dir/$subj/motion_censor.$subj.r02_05.1D
 #	else
 #		echo "motion_censor.$subj.r02_05.1D already exists!"
 #	endif
 #end
# ============================================================
set cc = 2
@ xx = $cc - 1
echo $xx
printf '%02d\n' $xx
# ============================================================
set from_dir = /Volumes/clmnlab/GL/fmri_data
set to_dir = /Volumes/T7SSD1/GL/fMRI_data

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

 #foreach ss ($subj_list)
 #	set subj = GL$ss
 #	set from = $from_dir/$subj/preprocessed/anat_final.{$subj}+tlrc.
 #	set to = $to_dir/$subj/anat_final.{$subj}.nii.gz
 #	3dAFNItoNIFTI -prefix $to $from
 #end
# ============================================================
 #set root_dir = /Volumes/T7SSD1/GL
 #set fmri_dir = $root_dir/fMRI_data
 #set preproc_dir = $fmri_dir/preproc_data
 #
 #foreach ss ($subj_list)
 #	set subj = GL$ss
 #	gzip -1v $preproc_dir/$subj/*.BRIK
 #end
# ============================================================
set from_dir = /Volumes/T7SSD1/GL/ppi
set to_dir = /Volumes/clmnlab/GL/sbPark.ppi/peak_seed_M1_and_S1
set roi_list = (M1 S1)

foreach roi ($roi_list)
	foreach ss ($subj_list)
		set subj = GL$ss
		cp $from_dir/PPIstat.$subj.$roi+tlrc.* $to_dir
	end
end
