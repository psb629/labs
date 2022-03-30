#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================
dir_root=/Volumes/clmnlab/GA
dir_fmri=$dir_root/fmri_data
dir_behav=$dir_root/behav_data

dir_mask=$fmri_dir/masks
dir_stat=$fmri_dir/stats
# ============================================================
dir_output=
if [ ! -d $work_dir ]; then
	mkdir -p -m 755 $work_dir
fi
# ============================================================
foreach nn ($nn_list)
	foreach gg ('GA' 'GB')
		subj=$gg$nn
		foreach run (`seq -f "r%02g" 1 6`)
			## main
			3dTproject \
				-polort 0 \
				-input /Volumes/clmnlab/GA/fmri_data/preproc_data/GA01/pb04.GA01.r01.scale+tlrc \
				-mask /Volumes/clmnlab/GA/fmri_data/preproc_data/GA01/full_mask.GA01+tlrc \
				-passband 0.01 0.1 \
				-censor /Volumes/clmnlab/GA/fmri_data/preproc_data/GA01/motion_GA01.r01_censor.1D \
				-cenmode ZERO \
				-ort /Volumes/clmnlab/GA/fmri_data/preproc_data/GA01/motion_demean.GA01.r01.1D \
				-ort global
				-prefix /Users/clmn/Desktop/GA/fmri_data/pb04.errts_tproject/01/errts.tproject.GA01.r01.nii
		end
	end
end
# ============================================================
