#!/bin/tcsh

set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
# set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)
# outliers : GD29, GD31
# No data : GD19
set dname = GLM.move-stop
# ============================================================
set data_dir = /Volumes/

set root_dir = /Volumes/T7SSD1/GA
set behav_dir = $root_dir/behav_data
set reg_dir = $behav_dir/regressors
set fmri_dir = $root_dir/fMRI_data
set mask_dir = $fmri_dir/roi/full
set stats_dir = $fmri_dir/stats
set runs = (r01 r02 r03 r04 r05 r06)
# ============================================================
foreach nn ($subj_list)
	## check the existence
	set temp = $data_dir
	if (! -d $temp) then
		echo "need to make $temp's regressors first!"
		continue
	endif
	## make output directory
	set output_dir = $stats_dir/$dname
	if (! -d $output_dir) then
		mkdir -p -m 755 $output_dir
	endif
	# ============================================================
	cd $output_dir
	# 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
	3dDeconvolve -input $preproc_dir/pb04.GA$nn.r00.scale+tlrc.HEAD \
			 -mask $mask_dir/full_mask.GA$nn.nii.gz \
			 -censor $preproc_dir/motion_GA$nn.r00_censor.1D \
			 -polort A -float \
			 -local_times \
			 -num_stimts 8 \
			 -num_glt 1 \
			 -stim_times_AM1 1 $reg_dir/${nn}_Move.txt dmBLOCK \
			 -stim_label 1 Move \
			 -stim_times_AM1 2 $reg_dir/${nn}_Stop.txt dmBLOCK \
			 -stim_label 2 Stop \
			 -stim_file 3 "motion_demean.Ga$nn.r00.1D[0]" -stim_base 3 -stim_label 3 roll \
			 -stim_file 4 "motion_demean.GA$nn.r00.1D[1]" -stim_base 4 -stim_label 4 pitch \
			 -stim_file 5 "motion_demean.GA$nn.r00.1D[2]" -stim_base 5 -stim_label 5 yaw \
			 -stim_file 6 "motion_demean.GA$nn.r00.1D[3]" -stim_base 6 -stim_label 6 dS \
			 -stim_file 7 "motion_demean.GA$nn.r00.1D[4]" -stim_base 7 -stim_label 7 dL \
			 -stim_file 8 "motion_demean.GA$nn.r00.1D[5]" -stim_base 8 -stim_label 8 dP \
			 -gltsym 'SYM: Move -Stop' \
			 -glt_label 1 Move-Stop \
			 -jobs 4 -fout -tout \
			 -x1D ./X.xmat.1D \
			 -xjpeg ./X.jpg \
			 -x1D_uncensored ./X.nocensor.xmat.1D \
			 -bucket ./statMove.$nn
	# ============================================================
	cd $subj_stats_dir
	set pname = $output_dir/temp.$subj

	3dMean -prefix $pname \
		$output_dir/statsRWDtime.$subj.r01.SPMG2+tlrc.HEAD \
		$output_dir/statsRWDtime.$subj.r02.SPMG2+tlrc.HEAD \
		$output_dir/statsRWDtime.$subj.r03.SPMG2+tlrc.HEAD
	3dcalc -a $pname+tlrc.HEAD'[5]' -expr a -prefix $output_dir/statsRWDtime.$subj.run1to3.SPMG2
	rm $pname+tlrc.*
	3dAFNItoNIFTI -prefix $output_dir/statsRWDtime.$subj.run1to3.SPMG2.nii.gz $output_dir/statsRWDtime.$subj.run1to3.SPMG2+tlrc.
	# ============================================================
	gzip -1v $output_dir/*.BRIK
	# ============================================================
	echo "subject GA$nn completed"
end
