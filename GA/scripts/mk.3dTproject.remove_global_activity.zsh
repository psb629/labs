#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================
root_dir=/Volumes/GoogleDrive/내\ 드라이브/GA
behav_dir=$root_dir/behav_data
fmri_dir=$root_dir/fMRI_data
roi_dir=$fmri_dir/roi
stats_dir=$fmri_dir/stats
# ============================================================
foreach nn ($nn_list)
	foreach gg (GA GB)
		subj=$gg$nn
		## move main files to the temp_dir directory
		mask=full_mask.$subj.nii.gz
		foreach rr (`count -digits 2 1 6`)
			3dTproject -polort 0 -input $output_dir/$subj.errts.MO.RO.r$rr.nii.gz \
					-ort 
					-mask $temp_dir/$mask \
					-passband 0.01 0.1 \
					-cenmode ZERO \
					-prefix $fin_res
		end
	end
end
