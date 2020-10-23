#!/bin/tcsh

#set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)
set subj_list = (GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)

set root_dir = /Volumes/T7SSD1/GD
set data_dir = $root_dir/connectivity/rest_WM_Vent_BP
set output_dir = $data_dir/CorrZ.caudate

set roi = (caudate_head_R caudate_body_R caudate_tail_R caudate_head_L caudate_body_L caudate_tail_L)

foreach n (`count -digit 1 1 $#roi`)
	set temp = ()
	@ n = $n - 1
	foreach subj ($subj_list)
		set pname = $output_dir/CorrZ.caudate.$subj.rest.WM
		if ( ! -e $pname+tlrc.HEAD ) then
			3dTcorr1D -pearson -Fisher -mask $root_dir/fMRI_data/masks/full/full_mask.$subj.nii.gz \
				-prefix $pname \
				$data_dir/errts.$subj.rest+tlrc \
				$data_dir/errts.caudate.$subj.rest.2D
		endif
    	## head_R, body_R, tail_R, head_L, body_L, tail_L
		set pname = $output_dir/CorrZ.$roi[$n].$subj.rest.WM
		3dcalc -prefix $pname -a "$output_dir/CorrZ.caudate.$subj.rest.WM+tlrc.HEAD[$n]" -expr a
		set temp = ($temp $pname+tlrc.HEAD)
	end
	3dbucket -prefix $output_dir/CorrZ.$roi[$n].GA.n$#subj_list.rest.WM $temp
end

