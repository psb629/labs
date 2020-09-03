#!/bin/tcsh

set subj_list = (\
				TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT TML10_PILOT TML11_PILOT\
				TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20\
				TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29\
				)
set output_reg_num = Reg5
set stat_name = {$output_reg_num}_MVPA1_IM_vibration	# Vibration

set TM_dir = /clmnlab/TM
set basisV = 'BLOCK(1,1)'

foreach subj ($subj_list)
	set preproc_subj_dir = $TM_dir/fMRI_data/preproc_data/$subj/preprocessed
	if (! -d $preproc_subj_dir) then
		continue
	endif
	set reg_subj_dir = $TM_dir/behav_data/regressors/$subj
	if (! -d $reg_subj_dir) then
		continue
	endif
	set stat_subj_dir = $TM_dir/fMRI_data/stats/$stat_name/$subj
	if (! -d $stat_subj_dir) then
		mkdir -p -m 777 $stat_subj_dir
	endif

	set reg_file = $reg_subj_dir/onset_vibration.dat
	set temp_file = $reg_subj_dir/tempV.dat

	foreach run (r01 r02 r03)
		sed -n "`echo $run | cut -c3`p" $reg_file > $temp_file

		3dDeconvolve -input $preproc_subj_dir/pb04.$subj.$run.scale+tlrc	\
			-mask $preproc_subj_dir/full_mask.$subj+tlrc.HEAD	\
			-censor $preproc_subj_dir/motion_${subj}_censor.1D	\
			-polort A -float		\
			-local_times			\
			-num_stimts 7			\
			-stim_times_IM 1 $temp_file $basisV \
			-stim_label 1 Vibration	\
			-stim_file 2 $preproc_subj_dir/motion_demean.$subj.1D'[0]' -stim_base 2 -stim_label 2 roll	\
			-stim_file 3 $preproc_subj_dir/motion_demean.$subj.1D'[1]' -stim_base 3 -stim_label 3 pitch	\
			-stim_file 4 $preproc_subj_dir/motion_demean.$subj.1D'[2]' -stim_base 4 -stim_label 4 yaw	\
			-stim_file 5 $preproc_subj_dir/motion_demean.$subj.1D'[3]' -stim_base 5 -stim_label 5 dS	\
			-stim_file 6 $preproc_subj_dir/motion_demean.$subj.1D'[4]' -stim_base 6 -stim_label 6 dL	\
			-stim_file 7 $preproc_subj_dir/motion_demean.$subj.1D'[5]' -stim_base 7 -stim_label 7 dP	\
			-num_glt 1				\
			-gltsym "SYM: Vibration"\
			-glt_label 1 Vibration	\
			-fout -tout -x1D $stat_subj_dir/$run.X.xmat.1D -xjpeg $stat_subj_dir/$run.X.jpg	\
			-x1D_uncensored $stat_subj_dir/$run.X.nocensor.xmat.1D		\
			-bucket $stat_subj_dir/$run.stat.$subj
		3dLSS -input $preproc_subj_dir/pb04.$subj.$run.scale+tlrc.HEAD	\
			-mask $preproc_subj_dir/full_mask.$subj+tlrc.HEAD			\
			-matrix $stat_subj_dir/$run.X.xmat.1D	\
			-save1D $stat_subj_dir/$run.X.LSS.1D		\
			-prefix $stat_subj_dir/$run.LSSout
		3dAFNItoNIFTI -prefix $stat_subj_dir/$run.LSSout.nii.gz $stat_subj_dir/$run.LSSout+tlrc
	end

 	rm $temp_file
	echo "subject $subj completed"
end
