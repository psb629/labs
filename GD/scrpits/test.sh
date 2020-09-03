#!/bin/tcsh

set subj_list = (GD29)
set subj_list = (GD02 GD07 GD11 GD30 GD29 GD32 GD23 GD01 GD31)
set output_reg_num = Reg1
set dname = {$output_reg_num}_GLM_test
# ============================================================
set root_dir = /clmnlab/GD
set behav_dir = $root_dir/behav_data
set reg_dir = $behav_dir/regressors
set fMRI_dir = $root_dir/fMRI_data
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
	endif
	set subj_stats_dir = $stats_dir/$dname/$subj
	if (! -d $subj_stats_dir) then
		mkdir -p -m 777 $subj_stats_dir
	endif
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

