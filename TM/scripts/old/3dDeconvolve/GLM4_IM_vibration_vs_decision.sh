#!/bin/tcsh

set subj_list = (TML03_PILOT)
set reg_num = Reg1
set output_reg_num = Reg4
set stat_name = {$output_reg_num}_GLM_IM_vibration_vs_decision

set basisV = 'BLOCK(1,1)'
set basisC = 'BLOCK(1.5,1)'

set TM_dir = /clmnlab/TM

foreach subj ($subj_list)
	set preproc_subj_dir = $TM_dir/fMRI_data/preproc_data/$subj/preprocessed
	if (! -d $preproc_subj_dir) then
		continue
	endif
	set reg_dir = $TM_dir/behav_data/regressors/$reg_num/$subj
	if (! -d $reg_dir) then
		continue
	endif
	set stat_dir = $TM_dir/fMRI_data/stats/$stat_name/$subj
	if (! -d $stat_dir) then
		mkdir -p -m 777 $stat_dir
	endif

	cd $stat_dir
	foreach run (r01 r02 r03)
		sed -n "`echo $run | cut -c3`p" $reg_dir/Reg_{$subj}_onsettime_Vibration.txt > $reg_dir/tempV.txt
		sed -n "`echo $run | cut -c3`p" $reg_dir/Reg_{$subj}_onsettime_Decision.txt > $reg_dir/tempC.txt
		3dDeconvolve -input $preproc_subj_dir/pb04.$subj.$run.scale+tlrc	\
			-mask $preproc_subj_dir/full_mask.$subj+tlrc.HEAD	\
			-censor $preproc_subj_dir/motion_{$subj}_censor.1D	\
			-polort A -float		\
			-local_times			\
			-num_stimts 8			\
			-stim_times_IM 1 $reg_dir/tempV.txt $basisV	\
			-stim_label 1 Vibration	\
			-stim_times 2 $reg_dir/tempC.txt $basisC 	\
			-stim_label 2 Decision\
			-stim_file 3 $preproc_subj_dir/motion_demean.$subj.1D'[0]' -stim_base 3 -stim_label 3 roll\
			-stim_file 4 $preproc_subj_dir/motion_demean.$subj.1D'[1]' -stim_base 4 -stim_label 4 pitch\
			-stim_file 5 $preproc_subj_dir/motion_demean.$subj.1D'[2]' -stim_base 5 -stim_label 5 yaw\
			-stim_file 6 $preproc_subj_dir/motion_demean.$subj.1D'[3]' -stim_base 6 -stim_label 6 dS	\
			-stim_file 7 $preproc_subj_dir/motion_demean.$subj.1D'[4]' -stim_base 7 -stim_label 7 dL	\
			-stim_file 8 $preproc_subj_dir/motion_demean.$subj.1D'[5]' -stim_base 8 -stim_label 8 dP	\
			-num_glt 2				\
			-gltsym "SYM: Vibration"		\
			-glt_label 1 Vibration			\
			-gltsym "SYM: Decision"			\
			-glt_label 2 Decision			\
			-fout -tout -x1D $stat_dir/$run.X.xmat.1D -xjpeg $stat_dir/$run.X.jpg	\
			-x1D_uncensored $stat_dir/$run.X.nocensor.xmat.1D					\
			-bucket $stat_dir/$run.stat.$subj
		3dLSS -input $preproc_subj_dir/pb04.$subj.$run.scale+tlrc.HEAD	\
			-mask $preproc_subj_dir/full_mask.$subj+tlrc.HEAD			\
			-matrix $stat_dir/$run.X.xmat.1D	\
			-save1D $stat_dir/$run.X.LSS.1D		\
			-prefix $run.LSSout
		rm $reg_dir/tempV.txt $reg_dir/tempC.txt
	end

	echo "subject $subj completed"
end
