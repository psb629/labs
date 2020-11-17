#!/bin/tcsh

#set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15 GD38)
set subj_list = (GD38)
set output_reg_num = Reg1
set dname = {$output_reg_num}_GLM_test
# ============================================================
set root_dir = /Users/clmn/Desktop/GD
set behav_dir = $root_dir/behav_data
set reg_dir = $behav_dir/regressors
set fMRI_dir = /Volumes/T7SSD1/GD/fMRI_data
set stats_dir = $fMRI_dir/stats
set preproc_dir = $fMRI_dir/preproc_data
set runs = (r01 r02 r03 r04 r05 r06 r07)
# ============================================================
foreach subj ($subj_list)

	set subj_preproc_dir = $preproc_dir/$subj
	if (! -d $subj_preproc_dir) then
		echo "need to preprocess $subj's data first!"
		continue
	endif
	set subj_reg_dir = $reg_dir/$subj
	if (! -d $subj_reg_dir) then
		echo "need to make $subj's regressors first!"
		continue
	else
		chmod -R 777 $subj_reg_dir
	endif
	set subj_stats_dir = $stats_dir/$dname/$subj
	if (! -d $subj_stats_dir) then
		mkdir -p -m 777 $subj_stats_dir
	endif
	# ============================================================
	cd $preproc_dir/$subj/preprocessed

	foreach run ($runs)
		# 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
		3dDeconvolve \
			-input pb04.$subj.$run.scale+tlrc.HEAD \
			-censor motion_$subj.${run}_censor.1D \
			-mask full_mask.$subj+tlrc \
			-polort A -float \
			-allzero_OK \
			-num_stimts 7 \
			-stim_times_AM2 1 $subj_reg_dir/$subj.${run}rew1000.GAM.1D 'SPMG2' \
			-stim_label 1 rwdtm \
			-stim_file 2 "motion_demean.$subj.$run.1D[0]" -stim_base 2 -stim_label 2 roll \
			-stim_file 3 "motion_demean.$subj.$run.1D[1]" -stim_base 3 -stim_label 3 pitch \
			-stim_file 4 "motion_demean.$subj.$run.1D[2]" -stim_base 4 -stim_label 4 yaw \
			-stim_file 5 "motion_demean.$subj.$run.1D[3]" -stim_base 5 -stim_label 5 dS \
			-stim_file 6 "motion_demean.$subj.$run.1D[4]" -stim_base 6 -stim_label 6 dL \
			-stim_file 7 "motion_demean.$subj.$run.1D[5]" -stim_base 7 -stim_label 7 dP \
			-gltsym 'SYM: rwdtm' \
			-glt_label 1 rwdtm \
			-jobs 8 -fout -tout -x1D $subj_stats_dir/X.xmat.$subj.$run.SPMG2.1D -xjpeg $subj_stats_dir/X.$subj.$run.SPMG2.jpg \
			-bucket $subj_stats_dir/statsRWDtime.$subj.$run.SPMG2 \
			-errts $subj_stats_dir/errts.$subj.$run.SPMG2
		3dAFNItoNIFTI -prefix $subj_stats_dir/statsRWDtime.$subj.$run.SPMG2.nii.gz $subj_stats_dir/statsRWDtime.$subj.$run.SPMG2+tlrc.
	end
	# ============================================================
	cd $subj_stats_dir
	set pname = temp.$subj

	3dMean -prefix $pname \
		statsRWDtime.$subj.r01.SPMG2+tlrc.HEAD \
		statsRWDtime.$subj.r02.SPMG2+tlrc.HEAD \
		statsRWDtime.$subj.r03.SPMG2+tlrc.HEAD
	3dcalc -a $pname+tlrc.HEAD'[5]' -expr a -prefix statsRWDtime.$subj.run1to3.SPMG2
	rm $pname+tlrc.*
	3dAFNItoNIFTI -prefix statsRWDtime.$subj.run1to3.SPMG2.nii.gz statsRWDtime.$subj.run1to3.SPMG2+tlrc.

	3dMean -prefix $pname \
		statsRWDtime.$subj.r04.SPMG2+tlrc.HEAD \
		statsRWDtime.$subj.r05.SPMG2+tlrc.HEAD \
		statsRWDtime.$subj.r06.SPMG2+tlrc.HEAD
	3dcalc -a $pname+tlrc.HEAD'[5]' -expr a -prefix statsRWDtime.$subj.run4to6.SPMG2
	rm $pname+tlrc.*
	3dAFNItoNIFTI -prefix statsRWDtime.$subj.run4to6.SPMG2.nii.gz statsRWDtime.$subj.run4to6.SPMG2+tlrc.
	# ============================================================
	gzip -1v ./*.BRIK
	# ============================================================
	echo "subject $subj completed"

end
