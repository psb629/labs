#!/bin/tcsh

set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15 38)

set root_dir = /Volumes/T7SSD1/GD
set behav_dir = $root_dir/behav_data
set data_dir = $root_dir/connectivity/rest_WM_Vent_BP/CorrZ.caudate
set output_dir = $data_dir/Corr.caudate

set date = 20201218

set roi_list = (caudate_head_R caudate_body_R caudate_tail_R caudate_head_L caudate_body_L caudate_tail_L)
set gmask = $root_dir/connectivity/rest_WM_Vent_BP/full_mask.GDs.n$#subj_list.nii.gz

foreach roi ($roi_list)
	# =======================================================
	## deconvolve the resting signal
	set pname = $output_dir/Corr.decon.$roi.GDs.n$#subj_list.rest.WM.rew_tot
	3dDeconvolve -input "$data_dir/CorrZ.$roi.GDs.n${#subj_list}.rest.WM.nii.gz" \
		-mask $gmask \
		-num_stimts 1 \
		-stim_file 1 $behav_dir/$date.rew_tot.GD.n${#subj_list}.1D -stim_label 1 rew_tot \
		-fout -tout -polort 0 -bucket $pname
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*
	# =======================================================
	## 
	set pname = $output_dir/Corr.$roi.GDs.n${#subj_list}.rest.WM.rew_tot
	3dTcorr1D -prefix $pname \
		-float -mask $gmask \
		"$data_dir/CorrZ.$roi.GDs.n${#subj_list}.rest.WM.nii.gz" $behav_dir/$date.rew_tot.GD.n${#subj_list}.1D
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*
	# =======================================================
#	3dDeconvolve -input "CorrZ.$roi.GA.All_n30.rest.WM+tlrc[0..27,29]" \
#		-mask $gmask
#		-num_stimts 1 -stim_file 1 lr_n29_ex_outlier.1D -stim_label 1 lr \
#		-fout -tout -polort 0 -bucket Corr.$roi.GA.lr.rest.WM_n29_ex_outlier
#	set pname = $output_dir/Corr.$roi[$n].GD.lr.rest.WM_n${#subj_list}.new
#	3dTcorr1D -prefix $pname \
#		-float -mask $gmask \
#		"CorrZ.$roi[$n].GD.All_n${#subj_list}.rest.WM+tlrc" lr_n${#subj_list}.1D
#	3dAFNItoNIFTI $pname+tlrc $output_dir/$roi[$n].GD.lr.rest.WM_n${#subj_list}.new
end
