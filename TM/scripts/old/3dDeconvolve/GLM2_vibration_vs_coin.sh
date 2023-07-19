#!/bin/tcsh

set subj_list = (TML03_PILOT)
set reg_num = Reg2

set stats_name = {$reg_num}_GLM_vibration_vs_coin
set TM_dir = /clmnlab/TM

set basisV = 'BLOCK(1,1)'
set basisC = 'BLOCK(0.5,1)'

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
	3dDeconvolve -input $root_dir/$subj/preprocessed/pb04.$subj.r01.scale+tlrc $root_dir/$subj/preprocessed/pb04.$subj.r02.scale+tlrc $root_dir/$subj/preprocessed/pb04.$subj.r03.scale+tlrc 	\
		-mask $root_dir/$subj/preprocessed/full_mask.$subj+tlrc.HEAD	\
		-censor $root_dir/$subj/preprocessed/motion_{$subj}_censor.1D	\
		-polort A -float		\
		-local_times			\
		-num_stimts 9			\
		-stim_times 1 $reg_dir/Reg_{$subj}_onsettime_Vibration.txt $basisV	\
		-stim_label 1 Vibration	\
		-stim_times 2 $reg_dir/Reg_{$subj}_onsettime_Coin100.txt $basisC	\
		-stim_label 2 Coin100	\
		-stim_times 3 $reg_dir/Reg_{$subj}_onsettime_Coin0.txt $basisC		\
		-stim_label 3 Coin0		\
		-stim_file 4 motion_demean.$subj.1D'[0]' -stim_base 4 -stim_label 4 roll\
		-stim_file 5 motion_demean.$subj.1D'[1]' -stim_base 5 -stim_label 5 pitch\
		-stim_file 6 motion_demean.$subj.1D'[2]' -stim_base 6 -stim_label 6 yaw	\
		-stim_file 7 motion_demean.$subj.1D'[3]' -stim_base 7 -stim_label 7 dS	\
		-stim_file 8 motion_demean.$subj.1D'[4]' -stim_base 8 -stim_label 8 dL	\
		-stim_file 9 motion_demean.$subj.1D'[5]' -stim_base 9 -stim_label 9 dP	\
		-num_glt 5						\
		-gltsym "SYM: Vibration"		\
		-glt_label 1 Vibration			\
		-gltsym "SYM: Coin100 +Coin0"	\
		-glt_label 2 sum_sum100_sum0	\
		-gltsym "SYM: Coin100 -Coin0"	\
		-glt_label 3 diff_sum100_sum0	\
		-gltsym "SYM: Coin100"			\
		-glt_label 4 Coin100			\
		-gltsym "SYM: Coin0"			\
		-glt_label 5 Coin0				\
		-iresp 1 $stats_dir/Vibration.$subj.iresp	\
		-iresp 2 $stats_dir/sum_sum100_sum0.$subj.iresp	\
		-iresp 3 $stats_dir/diff_sum100_sum0.$subj.iresp\
		-iresp 4 $stats_dir/Coin100.$subj.iresp	\
		-iresp 5 $stats_dir/Coin0.$subj.iresp	\
		-fout -tout -x1D $stats_dir/X.xmat.1D -xjpeg $stats_dir/X.jpg	\
		-x1D_uncensored $stats_dir/X.nocensor.xmat.1D					\
		-bucket $stats_dir/stat.$subj
	echo "subject $subj completed"
end
