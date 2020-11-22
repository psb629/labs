#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
set output_reg_num = Reg1
set dname = {$output_reg_num}_GLM_feedback

# ============================================================
set root_dir = /Volumes/T7SSD1/GL
set fMRI_dir = $root_dir/fMRI_data
set preproc_dir = $fMRI_dir/preproc_data
set roi_dir = $root_dir/roi
set reg_dir = $root_dir/behav_data/regressors
set stats_dir = $fMRI_dir/stats
# ============================================================
foreach ss ($subj_list)
	set subj = GL$ss
	if (! -d $preproc_dir/$subj) then
		echo "need to preprocess $subj's data first!"
		continue
	endif
	set output_dir = $stats_dir/$dname/$subj
	if (! -d $output_dir) then
		mkdir -p -m 755 $output_dir
	endif
	# ============================================================
	3dDeconvolve -input $preproc_dir/$subj/pb04.$subj.r02.scale+tlrc.HEAD\
						$preproc_dir/$subj/pb04.$subj.r03.scale+tlrc.HEAD\
						$preproc_dir/$subj/pb04.$subj.r04.scale+tlrc.HEAD\
						$preproc_dir/$subj/pb04.$subj.r05.scale+tlrc.HEAD\
		-censor $preproc_dir/$subj/motion_censor.$subj.r02_05.1D \
		-mask $roi_dir/full/full_mask.$subj.nii.gz \
		-polort A -float \
		-allzero_OK \
		-num_stimts 8 \
		-stim_times_AM1 1 $reg_dir/${subj}_FB.txt 'dmBLOCK(1)' -stim_label 1 FB \
		-stim_times_AM1 2 $reg_dir/${subj}_nFB.txt 'dmBLOCK(1)' -stim_label 2 nFB \
		-stim_file 3 $preproc_dir/$subj/"motion_demean.$subj.r02_05.1D[0]" -stim_base 3 -stim_label 3 roll \
		-stim_file 4 $preproc_dir/$subj/"motion_demean.$subj.r02_05.1D[1]" -stim_base 4 -stim_label 4 pitch \
		-stim_file 5 $preproc_dir/$subj/"motion_demean.$subj.r02_05.1D[2]" -stim_base 5 -stim_label 5 yaw \
		-stim_file 6 $preproc_dir/$subj/"motion_demean.$subj.r02_05.1D[3]" -stim_base 6 -stim_label 6 dS \
		-stim_file 7 $preproc_dir/$subj/"motion_demean.$subj.r02_05.1D[4]" -stim_base 7 -stim_label 7 dL \
		-stim_file 8 $preproc_dir/$subj/"motion_demean.$subj.r02_05.1D[5]" -stim_base 8 -stim_label 8 dP \
		-gltsym 'SYM: FB -nFB' \
		-glt_label 1 diff \
		-jobs 2 -fout -tout -x1D $output_dir/X.xmat.$subj.1D -xjpeg $output_dir/X.$subj.jpg \
		-bucket $output_dir/stats.$subj \
		-errts $output_dir/errts.$subj
	3dAFNItoNIFTI -prefix $output_dir/stats.$subj.nii.gz $output_dir/stats.$subj+tlrc
	rm $output_dir/stats.$subj+tlrc.*
	# ============================================================
	gzip -1v $output_dir/*.BRIK
	# ============================================================
	echo "subject $subj completed"

end
