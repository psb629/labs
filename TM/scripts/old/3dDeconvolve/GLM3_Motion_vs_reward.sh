#!/bin/tcsh

set subj_list = (TMH06 TML07 TMH08)
set reg_num = Reg3
set stats_name = {$reg_num}_GLM_Motion_vs_reward

set TM_dir = /clmnlab/TM

set basisV = 'BLOCK(1,1)'
set basisC = 'BLOCK(0.5,1)'

foreach subj ($subj_list)
	set freqType = (`echo $subj | cut -c3`)
	if ("$freqType" == "L")	then
		set freq = (`count -digit 2 14 26`)
	else if ("$freqType" == "H") then
		set freq = (`count -digit 2 34 46`)
	endif

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
		-num_stimts 23			\
		-stim_times 1 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[1]}.txt $basisV	\
		-stim_label 1 Freq_{$freq[1]}	\
		-stim_times 2 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[2]}.txt $basisV	\
		-stim_label 2 Freq_{$freq[2]}	\
		-stim_times 3 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[3]}.txt $basisV	\
		-stim_label 3 Freq_{$freq[3]}	\
		-stim_times 4 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[4]}.txt $basisV	\
		-stim_label 4 Freq_{$freq[4]}	\
		-stim_times 5 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[5]}.txt $basisV	\
		-stim_label 5 Freq_{$freq[5]}	\
		-stim_times 6 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[6]}.txt $basisV	\
		-stim_label 6 Freq_{$freq[6]}	\
		-stim_times 7 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[7]}.txt $basisV	\
		-stim_label 7 Freq_{$freq[7]}	\
		-stim_times 8 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[8]}.txt $basisV	\
		-stim_label 8 Freq_{$freq[8]}	\
		-stim_times 9 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[9]}.txt $basisV	\
		-stim_label 9 Freq_{$freq[9]}	\
		-stim_times 10 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[10]}.txt $basisV	\
		-stim_label 10 Freq_{$freq[10]}	\
		-stim_times 11 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[11]}.txt $basisV	\
		-stim_label 11 Freq_{$freq[11]}	\
		-stim_times 12 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[12]}.txt $basisV	\
		-stim_label 12 Freq_{$freq[12]}	\
		-stim_times 13 $reg_dir/Reg_{$subj}_onsettime_Freq_{$freq[13]}.txt $basisV	\
		-stim_label 13 Freq_{$freq[13]}	\
		-stim_times 14 $reg_dir/Reg_{$subj}_onsettime_Reward_U100.txt $basisC	\
		-stim_label 14 U_C100	\
		-stim_times 15 $reg_dir/Reg_{$subj}_onsettime_Reward_L100.txt $basisC	\
		-stim_label 15 L_C100	\
		-stim_times 16 $reg_dir/Reg_{$subj}_onsettime_Reward_U0.txt $basisC	\
		-stim_label 16 U_C0	\
		-stim_times 17 $reg_dir/Reg_{$subj}_onsettime_Reward_L0.txt $basisC	\
		-stim_label 17 L_C0	\
		-stim_file 18 motion_demean.$subj.1D'[0]' -stim_base 18 -stim_label 18 roll\
		-stim_file 19 motion_demean.$subj.1D'[1]' -stim_base 19 -stim_label 19 pitch\
		-stim_file 20 motion_demean.$subj.1D'[2]' -stim_base 20 -stim_label 20 yaw	\
		-stim_file 21 motion_demean.$subj.1D'[3]' -stim_base 21 -stim_label 21 dS	\
		-stim_file 22 motion_demean.$subj.1D'[4]' -stim_base 22 -stim_label 22 dL	\
		-stim_file 23 motion_demean.$subj.1D'[5]' -stim_base 23 -stim_label 23 dP	\
		-num_glt 20					\
		-gltsym "SYM: Freq_$freq[1]"		\
		-glt_label 1 Freq_{$freq[1]}		\
		-gltsym "SYM: Freq_$freq[2]"		\
		-glt_label 2 Freq_{$freq[2]}		\
		-gltsym "SYM: Freq_$freq[3]"		\
		-glt_label 3 Freq_{$freq[3]}		\
		-gltsym "SYM: Freq_$freq[4]"		\
		-glt_label 4 Freq_{$freq[4]}		\
		-gltsym "SYM: Freq_$freq[5]"		\
		-glt_label 5 Freq_{$freq[5]}		\
		-gltsym "SYM: Freq_$freq[6]"		\
		-glt_label 6 Freq_{$freq[6]}		\
		-gltsym "SYM: Freq_$freq[7]"		\
		-glt_label 7 Freq_{$freq[7]}		\
		-gltsym "SYM: Freq_$freq[8]"		\
		-glt_label 8 Freq_{$freq[8]}		\
		-gltsym "SYM: Freq_$freq[9]"		\
		-glt_label 9 Freq_{$freq[9]}		\
		-gltsym "SYM: Freq_$freq[10]"		\
		-glt_label 10 Freq_{$freq[10]}		\
		-gltsym "SYM: Freq_$freq[11]"		\
		-glt_label 11 Freq_{$freq[11]}		\
		-gltsym "SYM: Freq_$freq[12]"		\
		-glt_label 12 Freq_{$freq[12]}		\
		-gltsym "SYM: Freq_$freq[13]"		\
		-glt_label 13 Freq_{$freq[13]}		\
		-gltsym "SYM: U_C100 +U_C0"	\
		-glt_label 14 sum_UCoins	\
		-gltsym "SYM: U_C100 -U_C0"	\
		-glt_label 15 diff_UCoins	\
		-gltsym "SYM: L_C100 +L_C0"	\
		-glt_label 16 sum_LCoins	\
		-gltsym "SYM: L_C100 -L_C0"	\
		-glt_label 17 diff_LCoins	\
		-gltsym "SYM: U_C100 +U_C0 -L_C100 -L_C0"	\
		-glt_label 18 diff_sumU_sumL				\
		-gltsym "SYM: U_C100 +L_C100 -U_C0 -L_C0"	\
		-glt_label 19 diff_sum100_sum0				\
		-gltsym "SYM: U_C100 -U_C0 -L_C100 +L_C0"	\
		-glt_label 20 diff_diffU_diffL				\
		-fout -tout -x1D $stats_dir/X.xmat.1D -xjpeg $stats_dir/X.jpg	\
		-x1D_uncensored $stats_dir/X.nocensor.xmat.1D					\
		-bucket $stats_dir/stat.$subj
	echo "subject $subj completed"
end
