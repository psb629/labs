#!/bin/tcsh

set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)

set root_dir = /Volumes/T7SSD1/GD
set reg_dir = $root_dir/behav_data/regressors
set data_dir = $root_dir/connectivity/rest_WM_Vent_BP/CorrZ.caudate
set full_mask = $root_dir/fMRI_data/masks/full/full_mask.GDs_n$#subj_list.nii.gz
set output_dir = $data_dir/Corr.caudate

set roi_list = (caudate_head_R caudate_body_R caudate_tail_R caudate_head_L caudate_body_L caudate_tail_L)

cd $output_dir
foreach roi ($roi_list)
	# =======================================================
	3dDeconvolve -input "$data_dir/CorrZ.$roi.GD.n${#subj_list}.rest.WM+tlrc" \
		-mask $full_mask \
		-num_stimts 2 \
		-stim_file 1 $reg_dir/rew_tot.once.n${#subj_list}.1D -stim_label 1 rt_once \
		-stim_file 2 $reg_dir/rew_tot.whole.n${#subj_list}.1D -stim_label 2 rt_whole \
		-fout -tout -polort 0 -bucket Corr.$roi.GD.rew_tot.once.rest.WM_n$#subj_list

	set pname = Corr.$roi.GD.rew_tot.once.rest.WM_n${#subj_list}.new
	3dTcorr1D -prefix $pname \
		-float -mask $full_mask \
		"$data_dir/CorrZ.$roi.GD.n${#subj_list}.rest.WM+tlrc" $reg_dir/rew_tot.once.n${#subj_list}.1D
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc.

	set pname = Corr.$roi.GD.rew_tot.whole.rest.WM_n${#subj_list}.new
	3dTcorr1D -prefix $pname \
		-float -mask $full_mask \
		"$data_dir/CorrZ.$roi.GD.n${#subj_list}.rest.WM+tlrc" $reg_dir/rew_tot.whole.n${#subj_list}.1D
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc.
	# =======================================================
#	3dDeconvolve -input "CorrZ.$roi.GA.All_n30.rest.WM+tlrc[0..27,29]" \
#		-mask $full_mask
#		-num_stimts 1 -stim_file 1 lr_n29_ex_outlier.1D -stim_label 1 lr \
#		-fout -tout -polort 0 -bucket Corr.$roi.GA.lr.rest.WM_n29_ex_outlier
#	set pname = $output_dir/Corr.$roi[$n].GD.lr.rest.WM_n${#subj_list}.new
#	3dTcorr1D -prefix $pname \
#		-float -mask $full_mask \
#		"CorrZ.$roi[$n].GD.All_n${#subj_list}.rest.WM+tlrc" lr_n${#subj_list}.1D
#	3dAFNItoNIFTI $pname+tlrc $output_dir/$roi[$n].GD.lr.rest.WM_n${#subj_list}.new
end
gzip -1v ./*.BRIK
# cp $root_dir/fMRI_data/preproc_data/$subj_list[1]/preprocessed/anat_final.$subj_list[1]+tlrc.* ./
