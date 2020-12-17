#!/bin/tcsh

set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15 38)

set root_dir = /Volumes/T7SSD1/GD
set roi_dir = $root_dir/fMRI_data/roi
set data_dir = $root_dir/connectivity/rest_WM_Vent_BP
set output_dir = $data_dir/CorrZ.caudate

set roi = (caudate_head_R caudate_body_R caudate_tail_R caudate_head_L caudate_body_L caudate_tail_L)

foreach aa (`count -digits 1 1 $#roi`)
	@ bb = $aa - 1
	set temp = ()
	foreach nn ($subj_list)
		set subj = GD$nn
		set pname = $output_dir/CorrZ.caudate.$subj.rest.WM
		if ( ! -e $pname+tlrc.HEAD ) then
			3dTcorr1D -pearson -Fisher -mask $roi_dir/full/full_mask.$subj.nii.gz \
				-prefix $pname \
				$data_dir/errts.$subj.rest+tlrc \
				$data_dir/errts.caudate.$subj.rest.2D
		endif
    	## head_R, body_R, tail_R, head_L, body_L, tail_L
		set pname = $output_dir/CorrZ.$roi[$aa].$subj.rest.WM
		3dcalc -prefix $pname -a "$output_dir/CorrZ.caudate.$subj.rest.WM+tlrc.HEAD[$bb]" -expr a
		set temp = ($temp $pname+tlrc)
	end
	3dbucket $temp -prefix $output_dir/CorrZ.$roi[$aa].GDs.n$#subj_list.rest.WM
end

