#!/bin/tcsh

set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)

set root_dir = /Volumes/T7SSD1/GD
set data_dir = $root_dir/connectivity/rest_WM_Vent_BP/CorrZ.caudate
set full_mask = $root_dir/fMRI_data/masks/full/full_mask.GDs_n$#subj_list.nii.gz
set output_dir = $data_dir/Corr.caudate

set roi = (caudate_head_R caudate_body_R caudate_tail_R caudate_head_L caudate_body_L caudate_tail_L)

foreach n (`count -digit 1 1 $#roi`)
	@ n = $n - 1
	# =======================================================
	3dDeconvolve -input "CorrZ.$roi.GA.All_n30.rest.WM+tlrc[0..27,29]" \
		-mask /Volumes/clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30+tlrc \
		-num_stimts 1 -stim_file 1 rew_tot_n29_ex_outlier.1D -stim_label 1 rew_tot \
		-fout -tout -polort 0 -bucket Corr.$roi.GA.rew_tot.rest.WM_n29_ex_outlier

	3dDeconvolve -input "CorrZ.$roi.GA.All_n30.rest.WM+tlrc[0..27,29]" \
		-mask /Volumes/clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30+tlrc \
		-num_stimts 1 -stim_file 1 lr_n29_ex_outlier.1D -stim_label 1 lr \
		-fout -tout -polort 0 -bucket Corr.$roi.GA.lr.rest.WM_n29_ex_outlier
	# =======================================================
	set pname = $output_dir/Corr.$roi[$n].GD.lr.rest.WM_n${#subj_list}.new
	3dTcorr1D -prefix $pname \
		-float -mask $full_mask \
		"CorrZ.$roi[$n].GA.All_n${#subj_list}.rest.WM+tlrc" lr_n${#subj_list}.1D
	3dAFNItoNIFTI $pname+tlrc $output_dir/$roi[$n].GD.lr.rest.WM_n${#subj_list}.new

	set pname = $output_dir/Corr.$roi[$n].GD.rew_tot.rest.WM_n${#subj_list}.new
	3dTcorr1D -prefix $pname \
		-float -mask $full_mask \
		"CorrZ.$roi[$n].GA.All_n30.rest.WM+tlrc" rew_tot_n${#subj_list}.1D
	 3dAFNItoNIFTI Corr.$roi.GA.rew_tot.rest.WM_n${#subj_list}_ex_outlier.new+tlrc $roi[$n].GA.rew_tot.rest.WM_n${#subj_list}_ex_outlier.new
end

