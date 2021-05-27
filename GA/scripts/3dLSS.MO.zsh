#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================
data_dir=/Volumes/GoogleDrive/내\ 드라이브/GA/pb02
root_dir=/Volumes/GoogleDrive/내\ 드라이브/GA
behav_dir=$root_dir/behav_data
fmri_dir=$root_dir/fMRI_data
roi_dir=$fmri_dir/roi
stats_dir=$fmri_dir/stats
# ============================================================
output_dir=

foreach nn ($nn_list)
	foreach gg (GA GB)
		subj=$gg$nn
		foreach rr (`count -digits 2 1 6`)
			3dDeconvolve -nodata 1096 0.46 \
						-polort A -float \
						-num_stimts 8 \
						-num_glt 1 \
						-stim_times_IM 1 $behav_dir/regressors/4targets/$subj.IMregressor.4targets.r$rr.txt 'dmBLOCK' \
						-stim_file 2 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[0]" -stim_base 2 -stim_label 2 roll \
						-stim_file 3 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[1]" -stim_base 3 -stim_label 3 pitch \
						-stim_file 4 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[2]" -stim_base 4 -stim_label 4 yaw \
						-stim_file 5 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[3]" -stim_base 5 -stim_label 5 dS \
						-stim_file 6 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[4]" -stim_base 6 -stim_label 6 dL \
						-stim_file 7 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[5]" -stim_base 7 -stim_label 7 dP \
			            -stim_file 8 "$stats_dir/GLM.MO/$nn/$subj.X.MO.r$rr.1D'[5]" -stim_base 8 -stim_label 8 MO \
						-x1D_stop -x1D $output_dir/$subj.xmat.IM.4target.MO.r$rr
			
			3dLSS -verb \
					-input $data_dir/pb02.$subj.r$rr.volreg.nii.gz \
					-mask $roi_dir/full/full_mask.$subj.nii.gz \
					-matrix $output_dir/$subj.xmat.IM.4target.r$rr.1D \
					-save1D $output_dir/X.betas.LSS.MO.shortdur.$subj.r$rr \
					-prefix $output_dir/betasLSS.MO.shortdur.$subj.r$ss.nii.gz
		end
	end
end
