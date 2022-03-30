#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
list_nn=(01)
# ============================================================
dir_root=/mnt/sda2/GA
dir_behav=$dir_root/behav_data
dir_fmri=$dir_root/fMRI_data
dir_masks=$dir_fmri/masks
# ============================================================
foreach nn ($list_nn)
	dir_output=$dir_root/fmri_data/beta_map/$nn
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi
	foreach gg (GA GB)
		subj=$gg$nn
		foreach rr (`seq -f "%02g" 1 6`)
			3dDeconvolve -nodata 1096 0.46 \
						-polort A -float \
						-num_stimts 7 \
						-num_glt 1 \
						-stim_times_IM 1 "$dir_behav/regressors/4targets/$subj.IMregressor.4targets.r$rr.txt" 'dmBLOCK' \
						-stim_file 2 "$dir_fmri/preproc_data_from_NAS05/$subj/motion_demean.$subj.r$rr.1D[0]" -stim_base 2 -stim_label 2 roll \
						-stim_file 3 "$dir_fmri/preproc_data_from_NAS05/$subj/motion_demean.$subj.r$rr.1D[1]" -stim_base 3 -stim_label 3 pitch \
						-stim_file 4 "$dir_fmri/preproc_data_from_NAS05/$subj/motion_demean.$subj.r$rr.1D[2]" -stim_base 4 -stim_label 4 yaw \
						-stim_file 5 "$dir_fmri/preproc_data_from_NAS05/$subj/motion_demean.$subj.r$rr.1D[3]" -stim_base 5 -stim_label 5 dS \
						-stim_file 6 "$dir_fmri/preproc_data_from_NAS05/$subj/motion_demean.$subj.r$rr.1D[4]" -stim_base 6 -stim_label 6 dL \
						-stim_file 7 "$dir_fmri/preproc_data_from_NAS05/$subj/motion_demean.$subj.r$rr.1D[5]" -stim_base 7 -stim_label 7 dP \
						-x1D_stop -x1D $dir_output/$subj.r$rr.xmat.IM.4targets
			3dLSS -verb \
					-input $dir_fmri/preproc_data_from_NAS05/$subj/epi.volreg.$subj.r$rr.nii.gz \
					-mask $dir_masks/full/full_mask.$subj.nii.gz \
					-matrix $dir_output/$subj.r$rr.xmat.IM.4targets.1D \
					-save1D $dir_output/$subj.r$rr.X.betas.LSS \
					-prefix $dir_output/$subj.r$rr.betasLSS..nii
			cp $dir_output/$subj.r$rr.betasLSS.nii $dir_root/fmri_data/beta_map
		end
	end
	rm $dir_output
end
