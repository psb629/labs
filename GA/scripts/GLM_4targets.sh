#!/bin/tcsh

set id_list = (GA GB)
set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
# set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)
# outliers : GD29, GD31
# No data : GD19
set dname = Reg_GLM_4targets
# ============================================================
set root_dir = /Volumes/WD_HDD1/GA
set behav_dir = $root_dir/behav_data
set reg_dir = $behav_dir/regressors
set fmri_dir = $root_dir/fmri_data
set preproc_dir = $fmri_dir/preproc_data
set stats_dir = /Users/clmn/Desktop/GA/stats
set runs = (r01 r02 r03 r04 r05 r06)
# ============================================================
foreach ii ($id_list)
	foreach nn ($subj_list)
		set subj = $ii$nn
		## check the existence
		set temp = $preproc_dir/$subj
		if (! -d $temp) then
			echo "need to preprocess $subj's data first!"
			continue
		endif
		set temp = $reg_dir/$subj
		if (! -d $temp) then
			echo "need to make $subj's regressors first!"
			continue
		else
 #			chmod -R 777 $subj_reg_dir
		endif
		## make output directory
		set output_dir = $stats_dir/$dname/$subj
		if (! -d $output_dir) then
			mkdir -p -m 755 $output_dir
		endif
		# ============================================================
	    # caudate mask
 #		set mask_dir = $fmri_dir/masks/GA_caudate_roi/slicer_2/tlrc_resam_fullmask
 #		set pname = $mask_dir/${subj}_caudate.nii.gz
 #		if (! -e $pname ) then
 #			3dcalc \
 #				-a $mask_dir/${subj}_1_caudate_head_resam+tlrc \
 #				-b $mask_dir/${subj}_2_caudate_body_resam+tlrc \
 #				-c $mask_dir/${subj}_3_caudate_tail_resam+tlrc \
 #				-expr 'ispositive(a+b+c)' -prefix $pname
 #		endif
		# ============================================================
		cd 
		foreach run ($runs)
			# 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
			3dDeconvolve \
				-input $preproc_dir/$subj/pb04.$subj.$run.scale+tlrc.HEAD \
				-censor $preproc_dir/$subj/motion_$subj.${run}_censor.1D \
				-mask $mask_dir/${subj}_caudate.nii.gz \
				-polort A -float \
				-allzero_OK \
				-num_stimts 7 \
 #				-stim_times_AM2 1 $subj_reg_dir/$subj.${run}rew1000.GAM.1D 'SPMG2' \
	 			-stim_times_AM2 1 $subj_reg_dir/$temp.${run}rew1000.GAM.1D 'SPMG2' \
				-stim_label 1 rwdtm \
				-stim_file 2 $preproc_dir/$subj/"motion_demean.$subj.$run.1D[0]" -stim_base 2 -stim_label 2 roll \
				-stim_file 3 $preproc_dir/$subj/"motion_demean.$subj.$run.1D[1]" -stim_base 3 -stim_label 3 pitch \
				-stim_file 4 $preproc_dir/$subj/"motion_demean.$subj.$run.1D[2]" -stim_base 4 -stim_label 4 yaw \
				-stim_file 5 $preproc_dir/$subj/"motion_demean.$subj.$run.1D[3]" -stim_base 5 -stim_label 5 dS \
				-stim_file 6 $preproc_dir/$subj/"motion_demean.$subj.$run.1D[4]" -stim_base 6 -stim_label 6 dL \
				-stim_file 7 $preproc_dir/$subj/"motion_demean.$subj.$run.1D[5]" -stim_base 7 -stim_label 7 dP \
				-gltsym 'SYM: rwdtm' \
				-glt_label 1 rwdtm \
				-jobs 8 -fout -tout -x1D $output_dir/X.xmat.$subj.$run.SPMG2.1D -xjpeg $output_dir/X.$subj.$run.SPMG2.jpg \
				-bucket $output_dir/statsRWDtime.$subj.$run.SPMG2 \
				-errts $output_dir/errts.$subj.$run.SPMG2
			3dAFNItoNIFTI -prefix $output_dir/statsRWDtime.$subj.$run.SPMG2.nii.gz $output_dir/statsRWDtime.$subj.$run.SPMG2+tlrc.
		end
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
	
		3dMean -prefix $pname \
			$output_dir/statsRWDtime.$subj.r04.SPMG2+tlrc.HEAD \
			$output_dir/statsRWDtime.$subj.r05.SPMG2+tlrc.HEAD \
			$output_dir/statsRWDtime.$subj.r06.SPMG2+tlrc.HEAD
		3dcalc -a $pname+tlrc.HEAD'[5]' -expr a -prefix $output_dir/statsRWDtime.$subj.run4to6.SPMG2
		rm $pname+tlrc.*
		3dAFNItoNIFTI -prefix $output_dir/statsRWDtime.$subj.run4to6.SPMG2.nii.gz $output_dir/statsRWDtime.$subj.run4to6.SPMG2+tlrc.
		# ============================================================
		gzip -1v $output_dir/*.BRIK
		# ============================================================
		echo "subject $subj completed"
	end
end
