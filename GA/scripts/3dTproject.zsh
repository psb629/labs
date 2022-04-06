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

dir_local=/Users/clmn/Desktop/GA
dir_reg=$dir_local/txt
gmask=$dir_local/masks/full_mask.GAGB.nii.gz
# ============================================================
foreach nn ($nn_list)
	foreach gg ('GA' 'GB')
		subj=$gg$nn
		foreach run (`seq -f "r%02g" 1 6`)
			dir_output=/Volumes/T7-SSD2/GA/pb04.errts_tproject.RO.bp/$nn
			if [ ! -d $dir_output ]; then
				mkdir -p -m 755 $dir_output
			fi
			## main
			3dTproject \
				-polort 0 \
				-input $dir_fmri/preproc_data/$subj/pb04.$subj.$run.scale+tlrc \
				-mask $gmask \
				-passband 0.01 0.1 \
				-censor $dir_fmri/preproc_data/$subj/motion_$subj.${run}_censor.1D \
				-cenmode ZERO \
				-ort $dir_fmri/preproc_data/$subj/motion_demean.$subj.$run.1D \
				-ort $dir_reg/$subj.$run.SPMG2.reward.txt \
				-prefix $dir_output/pb04.errts_tproject.RO.bp.$subj.$run.nii
		end
	end
end
# ============================================================
