#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

set root_dir = /Volumes/T7SSD1/GL
set roi_dir = $root_dir/roi
set ppi_dir = $root_dir/ppi
set group_dir = $ppi_dir/group
set output_dir = $group_dir
#set output_dir = /Volumes/clmnlab/GL/sbPark.ppi

set roi_list = (M1 S1)
# ==========================================================
set RR_FB = $root_dir/behav_data/RewardRate_FB.txt
set brick_FB = 11 # ppi_FB#0_Coef
# ==========================================================
set RR_nFB = $root_dir/behav_data/RewardRate_nFB.txt
set brick_nFB = 14 # ppi_nFB#0_Coef
# ==========================================================
set RR_diff = $root_dir/behav_data/RewardRate_diff.txt
set brick_diff = 17 # ppiFB_ppinFB_GLT#0_Coef
# ==========================================================
set cond = FB
set RR = $RR_FB
set brick = $brick_FB
foreach roi ($roi_list)
	# ==========================================================
	## 3dbucket
	set temp = ()
	foreach nn ($subj_list)
		set subj = GL$nn
		set pname = $output_dir/temp.$subj.$roi.$cond
		3dcalc -prefix $pname -a "$ppi_dir/PPIstat.$subj.$roi+tlrc[$brick]" -expr a
		set temp = ($temp $pname+tlrc)
	end
	set buck = $output_dir/3dbucket.n$#subj_list.$roi.$cond
	3dbucket $temp -prefix $buck
	3dAFNItoNIFTI -prefix $buck.nii.gz $buck+tlrc
	rm $output_dir/temp.GL??.$roi.$cond+tlrc.* $buck+tlrc.*
	# ==========================================================
	## 3dTcorr1D
	set pname = $output_dir/corr.n$#subj_list.$roi.$cond
	3dTcorr1D -pearson -prefix $pname -float -mask $roi_dir/full/full_mask.group.n24.nii.gz $buck.nii.gz $RR
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*
end

