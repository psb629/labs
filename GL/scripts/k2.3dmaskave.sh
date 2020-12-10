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
foreach roi ($roi_list)

end
