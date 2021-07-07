#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 )
# ============================================================
dname=GLM.MO
# ============================================================
data_dir=/Volumes/GoogleDrive/내\ 드라이브/GA/pb02
root_dir=/Volumes/GoogleDrive/내\ 드라이브/GA
behav_dir=$root_dir/behav_data
fmri_dir=$root_dir/fMRI_data
roi_dir=$fmri_dir/roi
stats_dir=$fmri_dir/stats
# ============================================================
work_dir=~/Desktop/temp
if [ ! -d $work_dir ]; then
	mkdir -p -m 755 $work_dir
fi
# ============================================================
foreach nn ($nn_list)
	fin_dir=$stats_dir/GLM.MO/$nn
	if [ ! -d $fin_dir ]; then
		mkdir -p -m 755 $fin_dir
	fi
	foreach gg (GA GB)
		subj=$gg$nn
		## move the mask data to work_dir
		mask=full_mask.$subj.nii.gz
		cp -n $roi_dir/full/$mask $work_dir/$mask
		foreach rr (`seq -f "%02g" 1 6`)
			fin_res=$subj.global_activity.bp_demean.errts.MO.r$rr.nii.gz
			## move the input file to work_dir
			input=$subj.errts.MO.r$rr.nii.gz
			cp -n $stats_dir/GLM.MO/$nn/$input $work_dir/$input
			## main
			3dTproject -polort 0 -input $work_dir/$input\
					-ort $stats_dir/GLM.MO/tsmean/fan_all/$subj.errts.MO.r$rr.global_activity.1D \
					-mask $work_dir/$mask \
					-passband 0.01 0.1 \
					-cenmode ZERO \
					-prefix $work_dir/$fin_res
			## clear
			cp -n $work_dir/$fin_res $fin_dir/$fin_res
			rm $work_dir/$fin_res $work_dir/$input
		end
		## clear
		rm $work_dir/$mask
	end
end
# ============================================================
