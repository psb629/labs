#!/bin/tcsh

 #set subj_list = ( \
 #	TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT TML10_PILOT TML11_PILOT \
 #	TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20 \
 #	TML21 TML22 TML23 TML24 TML25 TML26 \
 #				)
set subj_list = (TML28 TML29)
set output_reg_num = Reg8
set stats_name = {$output_reg_num}_GLM_vibration_vs_yellow
##########################################################
# input files
# subj.Dis_freq_order.dat
# onset_vibration.dat
# onset_yellow.dat
##########################################################
set basisV = 'BLOCK(1,1)'
set basisY = 'BLOCK(1.5,1)'
set TM_dir = /clmnlab/TM

foreach subj ($subj_list)
	set preproc_subj_dir = $TM_dir/fMRI_data/preproc_data/$subj
	if (! -d $preproc_subj_dir) then
		continue
	endif
	set reg_subj_dir = $TM_dir/behav_data/regressors/$subj
	if (! -d $reg_subj_dir) then
		continue
	endif
	set stats_subj_dir = $TM_dir/fMRI_data/stats/$stats_name/$subj
	if (! -d $stats_subj_dir) then
		mkdir -p -m 777 $stats_subj_dir
	endif

	###############################################################
	set cf = '15.0'
	set order = `column -c 1 $TM_dir/behav_data/$subj/{$subj}.Dis_freq_order.dat`
	set tempC = $TM_dir/tempC.dat
	set tempO = $TM_dir/tempO.dat
	set tempY = $TM_dir/tempY.dat
	set onsets_V = ()
	set onsets_Y = ()
	foreach run (1 2 3)
		set onsets_V = ($onsets_V `sed -n {$run}p $reg_subj_dir/onset_vibration.dat`)
		set onsets_Y = ($onsets_Y `sed -n {$run}p $reg_subj_dir/onset_yellow.dat`)
	end
	if (-e $tempC) then
		rm $tempC
	endif
	if (-e $tempO) then
		rm $tempO
	endif
	if (-e $tempY) then
		rm $tempY
	endif
	foreach trial (`count -digit 1 1 100`)
		@ idx_before = $trial * 2 - 1
		@ idx_after = $trial * 2
		if ($order[$idx_before] == $cf) then
			echo -n $onsets_V[$idx_before]' ' >> $tempC
			echo -n $onsets_V[$idx_after]' ' >> $tempO
		else if ($order[$idx_after] == $cf) then
			echo -n $onsets_V[$idx_after]' ' >> $tempC
			echo -n $onsets_V[$idx_before]' ' >> $tempO
		else
			echo "error : trial = $trial, order[$idx_before] = $order[$idx_before], order[$idx_after] = $order[$idx_after]"
		endif
		echo -n $onsets_Y[$trial]' ' >> $tempY
		if ($trial == 40) then
			echo '' >> $tempC
			echo '' >> $tempO
			echo '' >> $tempY
		else if ($trial == 70) then
			echo '' >> $tempC
			echo '' >> $tempO
			echo '' >> $tempY
		endif
	end
	###############################################################

	cd $preproc_subj_dir/preprocessed/
	3dDeconvolve -input $preproc_subj_dir/preprocessed/pb04.$subj.r01.scale+tlrc $preproc_subj_dir/preprocessed/pb04.$subj.r02.scale+tlrc $preproc_subj_dir/preprocessed/pb04.$subj.r03.scale+tlrc	\
		-mask $preproc_subj_dir/preprocessed/full_mask.$subj+tlrc.HEAD	\
		-censor $preproc_subj_dir/preprocessed/motion_{$subj}_censor.1D	\
		-polort A -float		\
		-local_times			\
		-num_stimts 9			\
		-stim_times 1 $tempC $basisV	\
		-stim_label 1 center	\
		-stim_times 2 $tempO $basisV	\
		-stim_label 2 other		\
		-stim_times 3 $tempY $basisY 	\
		-stim_label 3 yellow	\
		-stim_file 4 motion_demean.$subj.1D'[0]' -stim_base 4 -stim_label 4 roll\
		-stim_file 5 motion_demean.$subj.1D'[1]' -stim_base 5 -stim_label 5 pitch\
		-stim_file 6 motion_demean.$subj.1D'[2]' -stim_base 6 -stim_label 6 yaw	\
		-stim_file 7 motion_demean.$subj.1D'[3]' -stim_base 7 -stim_label 7 dS	\
		-stim_file 8 motion_demean.$subj.1D'[4]' -stim_base 8 -stim_label 8 dL	\
		-stim_file 9 motion_demean.$subj.1D'[5]' -stim_base 9 -stim_label 9 dP	\
		-num_glt 3				\
		-gltsym "SYM: center"	\
		-glt_label 1 center		\
		-gltsym "SYM: other"	\
		-glt_label 2 other		\
		-gltsym "SYM: yellow"	\
		-glt_label 3 yellow		\
		-fout -tout -x1D $stats_subj_dir/X.xmat.1D -xjpeg $stats_subj_dir/X.jpg	\
		-x1D_uncensored $stats_subj_dir/X.nocensor.xmat.1D					\
		-bucket $stats_subj_dir/stat.$subj
	echo "subject $subj completed"
	rm $tempC $tempO $tempY
end
