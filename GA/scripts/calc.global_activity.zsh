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
mask=fan.roi.GA.all.nii.gz
# ============================================================
work_dir=~/Desktop/temp
if [ ! -d $work_dir ]; then
	mkdir -p -m 755 $work_dir
fi
cp -n $roi_dir/fan280/$mask $work_dir
# ============================================================
foreach nn ($nn_list)
	foreach gg (GA GB)
		subj=$gg$nn
		foreach run (r01 r02 r03 r04 r05 r06)
			data=$subj.errts.MO.RO.$run.nii.gz
			cp -n $stats_dir/GLM.MO.RO/$nn/$data $work_dir

			cd $work_dir
			3dmaskave -quiet -mask $mask $data > $subj.errts.MO.RO.$run.global_activity.1D
			rm $data
		end
	end
end
