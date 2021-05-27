#!/bin/zsh

root_dir=/Volumes/T7/re
output_dir=$root_dir

3dDeconvolve -nodata 360 2 \
			-polort A -float \
			-num_stimts 7 \
			-num_glt 1 \
			-stim_times_IM 1 $root_dir/regressor.r01.IM.txt 'dmBLOCK' \
			-stim_file 2 "$root_dir/motion_demean.HR01.rRun1.1D[0]" -stim_base 2 -stim_label 2 roll \
			-stim_file 3 "$root_dir/motion_demean.HR01.rRun1.1D[1]" -stim_base 3 -stim_label 3 pitch \
			-stim_file 4 "$root_dir/motion_demean.HR01.rRun1.1D[2]" -stim_base 4 -stim_label 4 yaw \
			-stim_file 5 "$root_dir/motion_demean.HR01.rRun1.1D[3]" -stim_base 5 -stim_label 5 dS \
			-stim_file 6 "$root_dir/motion_demean.HR01.rRun1.1D[4]" -stim_base 6 -stim_label 6 dL \
			-stim_file 7 "$root_dir/motion_demean.HR01.rRun1.1D[5]" -stim_base 7 -stim_label 7 dP \
			-x1D $output_dir/3dDcon.Xmat.1D -xjpeg $output_dir/3dDcon.Xmat.jpg
3dLSS -input $root_dir/pb02.HR01.rRun1.nii.gz \
	-mask $root_dir/full_mask.HR01.nii.gz \
	-matrix $root_dir/3dDcon.Xmat.1D \
	-save1D $output_dir/X.LSS.r01.1D \
	-prefix $output_dir/LSSout.r01.nii.gz
