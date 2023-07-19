#!/bin/tcsh

set subj_list = (TMH06 TML07 TMH08)
set reg_num = Reg1
set stats_name = {$reg_num}_GLM_vibration_vs_decision_TENT

set TM_dir = /clmnlab/TM

foreach subj ($subj_list)
	set root_dir = $TM_dir/fMRI_data/preproc_data
	if (! -d $root_dir) then
		continue
	endif
	set reg_dir = $TM_dir/behav_data/regressors/$reg_num/$subj
	if (! -d $reg_dir) then
		continue
	endif
	set stats_dir = $TM_dir/fMRI_data/stats/$stats_name/$subj
	if (! -d $stats_dir) then
		mkdir -p -m 777 $stats_dir
	endif

	cd $root_dir/$subj/preprocessed/
	3dDeconvolve -input $root_dir/$subj/preprocessed/pb04.$subj.r01.scale+tlrc $root_dir/$subj/preprocessed/pb04.$subj.r02.scale+tlrc $root_dir/$subj/preprocessed/pb04.$subj.r03.scale+tlrc 				\
		-mask $root_dir/$subj/preprocessed/full_mask.$subj+tlrc.HEAD	\
		-censor $root_dir/$subj/preprocessed/motion_{$subj}_censor.1D	\
		-polort A -float		\
		-local_times			\
		-num_stimts 8			\
		-stim_times 1 $reg_dir/Reg_{$subj}_onsettime_Vibration.txt 'TENT(0,12,7)'	\
		-stim_label 1 Vibration	\
		-stim_times 2 $reg_dir/Reg_{$subj}_onsettime_Decision.txt 'TENT(0,12,7)'	\
		-stim_label 2 Decision	\
		-stim_file 3 motion_demean.$subj.1D'[0]' -stim_base 3 -stim_label 3 roll\
		-stim_file 4 motion_demean.$subj.1D'[1]' -stim_base 4 -stim_label 4 pitch\
		-stim_file 5 motion_demean.$subj.1D'[2]' -stim_base 5 -stim_label 5 yaw	\
		-stim_file 6 motion_demean.$subj.1D'[3]' -stim_base 6 -stim_label 6 dS	\
		-stim_file 7 motion_demean.$subj.1D'[4]' -stim_base 7 -stim_label 7 dL	\
		-stim_file 8 motion_demean.$subj.1D'[5]' -stim_base 8 -stim_label 8 dP	\
		-num_glt 2				\
		-gltsym "SYM: Vibration"		\
		-glt_label 1 Vibration			\
		-gltsym "SYM: Decision"			\
		-glt_label 2 Decision			\
		-iresp 1 $stats_dir/Vibration.$subj.iresp	\
		-iresp 2 $stats_dir/Decision.$subj.iresp	\
		-fout -tout -x1D $stats_dir/X.xmat.1D -xjpeg $stats_dir/X.jpg	\
		-x1D_uncensored $stats_dir/X.nocensor.xmat.1D					\
		-bucket $stats_dir/stat.$subj
	echo "subject $subj completed"
end
