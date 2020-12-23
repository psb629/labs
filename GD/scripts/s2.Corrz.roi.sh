#!/bin/tcsh

set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15 38)

set root_dir = /Volumes/T7SSD1/GD
set roi_dir = $root_dir/fMRI_data/roi
set data_dir = $root_dir/connectivity/rest_WM_Vent_BP
set output_dir = $data_dir/CorrZ.caudate

set roi = (caudate_head_R caudate_body_R caudate_tail_R caudate_head_L caudate_body_L caudate_tail_L)

# ====================================================
## calculate correlation for each ROI
## An order of ROIs : head_R, body_R, tail_R, head_L, body_L, tail_L
foreach nn ($subj_list)
	set subj = GD$nn
	set calc_corr = $output_dir/CorrZ.caudate.$subj.rest.WM
	3dTcorr1D -pearson -Fisher -mask $roi_dir/full/full_mask.$subj.nii.gz \
		-prefix $calc_corr \
 #		$data_dir/errts.$subj.rest+tlrc \
		$data_dir/errts.$subj.rest.nii.gz \
		$data_dir/errts.caudate.$subj.rest.2D
	3dAFNItoNIFTI -prefix $calc_corr.nii.gz $calc_corr+tlrc
	rm $calc_corr+tlrc.*
end
# ====================================================
## make a 3dbucket of subject's dataset by ROI
foreach aa (`count -digits 1 1 $#roi`)
	@ bb = $aa - 1
	set gg = ()
	foreach nn ($subj_list)
		set subj = GD$nn
		set calc_corr = $output_dir/CorrZ.caudate.$subj.rest.WM
		# ====================================================
		## prepare to make a bucket
		set temp = $output_dir/temp.$roi[$aa].$subj.rest.WM
		3dcalc -prefix $temp -a "$calc_corr.nii.gz[$bb]" -expr a
		set gg = ($gg $temp+tlrc)
	end
	# ====================================================
	set pname = $output_dir/CorrZ.$roi[$aa].GDs.n$#subj_list.rest.WM
	3dbucket $gg -prefix $pname
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	# ====================================================
	## clean temporal files
	rm $output_dir/temp.* $pname+tlrc.*
end
