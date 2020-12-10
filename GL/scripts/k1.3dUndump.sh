#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
# =======================================================================
set root_dir = /Volumes/T7SSD1/GL
set fmri_dir = $root_dir/fMRI_data
#set preproc_dir = $fmri_dir/preproc_data
set roi_dir = $root_dir/roi
#set reg_dir = $root_dir/behav_data/regressors
#set ppi_dir = $root_dir/ppi
#set reg_psych_dir = $ppi_dir/reg
set stat_dir = $fmri_dir/stats/Reg1_{*}/group
set output_dir = $roi_dir
# =======================================================================
set roi_list = (M1 S1)
# =======================================================================
## coordinates where the value is peak for each ROI
set M1 = (-29 -7 71)
echo $M1 >$output_dir/M1.peak.xyz.1D
set S1 = (-59 -17 55)
echo $S1 >$output_dir/S1.peak.xyz.1D
# =======================================================================
set radius = 6		# unit: mm
foreach roi ($roi_list)
	set pname = $output_dir/3dUndump.$roi.group.rd$radius
	if (-e $pname+tlrc.HEAD) then
		rm $pname+tlrc.*
	endif
	set xyz1D = $output_dir/$roi.peak.xyz.1D
	3dUndump -prefix $pname -master $stat_dir/stats.group.n24.nii.gz -mask $roi_dir/full/full_mask.group.n24.nii.gz -srad $radius -xyz $output_dir/$roi.peak.xyz.1D
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*
end
