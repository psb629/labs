#!/bin/tcsh

set subj_list = (KJW)
set output_reg_num = Reg13
set stats_name = {$output_reg_num}_GLM_VibIsiYel
##########################################################
# input files
# subj.Dis_freq_order.dat
# onset_vibration.dat
# onset_yellow.dat
##########################################################
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
	set v_file = $reg_subj_dir/onset+duration_vibration.dat
	set temp_v1 = $reg_subj_dir/temp_v1.dat
	set temp_v2 = $reg_subj_dir/temp_v2.dat

	set isi_file = $reg_subj_dir/onset+duration_ISI12.dat
	set temp_i1 = $reg_subj_dir/temp_i1.dat
	set temp_i2 = $reg_subj_dir/temp_i2.dat

	set yel_file = $reg_subj_dir/onset+duration_yellow.dat

	foreach run (r01 r02 r03 r04 r05)
		set rr = `echo $run | cut -c3`
		set v = `sed -n "${rr}p" $v_file`
		set isi = `sed -n "${rr}p" $isi_file`
		set y = `sed -n "${rr}p" $yel_file`
	
		set num_trials = $#y
		foreach i (`count -digit 1 1 $num_trials`)
			@ before = $i * 2 - 1
			@ after = $i * 2
			echo -n $v[$before]' '  >> $temp_v1
			echo -n $v[$after]' '  >> $temp_v2
			echo -n $isi[$before]' '  >> $temp_i1
			echo -n $isi[$after]' '  >> $temp_i2
		end
		echo '' >> $temp_v1
		echo '' >> $temp_v2
		echo '' >> $temp_i1
		echo '' >> $temp_i2
	end

	cd $preproc_subj_dir/preprocessed/
	3dDeconvolve -input pb04.$subj.r01.scale+tlrc pb04.$subj.r02.scale+tlrc pb04.$subj.r03.scale+tlrc pb04.$subj.r04.scale+tlrc pb04.$subj.r05.scale+tlrc\
		-mask full_mask.$subj+tlrc.HEAD	\
		-censor motion_{$subj}_censor.1D	\
		-polort A -float		\
		-local_times			\
		-num_stimts 11			\
		-stim_times_AM1 1 $temp_v1 'dmBLOCK(1)'	\
		-stim_label 1 freq1	\
		-stim_times_AM1 2 $temp_i1 'dmBLOCK(1)'	\
		-stim_label 2 isi1		\
		-stim_times_AM1 3 $temp_v2 'dmBLOCK(1)'	\
		-stim_label 3 freq2	\
		-stim_times_AM1 4 $temp_i2 'dmBLOCK(1)'	\
		-stim_label 4 isi2		\
		-stim_times_AM1 5 $yel_file	'dmBLOCK(1)'\
		-stim_label 5 yellow	\
		-stim_file 6 motion_demean.$subj.1D'[0]' -stim_base 6 -stim_label 6 roll\
		-stim_file 7 motion_demean.$subj.1D'[1]' -stim_base 7 -stim_label 7 pitch\
		-stim_file 8 motion_demean.$subj.1D'[2]' -stim_base 8 -stim_label 8 yaw	\
		-stim_file 9 motion_demean.$subj.1D'[3]' -stim_base 9 -stim_label 9 dS	\
		-stim_file 10 motion_demean.$subj.1D'[4]' -stim_base 10 -stim_label 10 dL	\
		-stim_file 11 motion_demean.$subj.1D'[5]' -stim_base 11 -stim_label 11 dP	\
		-num_glt 5				\
		-gltsym "SYM: freq1"	\
		-glt_label 1 freq1		\
		-gltsym "SYM: isi1"		\
		-glt_label 2 isi1		\
		-gltsym "SYM: freq2"	\
		-glt_label 3 freq2		\
		-gltsym "SYM: isi2"		\
		-glt_label 4 isi2		\
		-gltsym "SYM: yellow"	\
		-glt_label 5 yellow		\
		-fout -tout -x1D $stats_subj_dir/X.xmat.1D -xjpeg $stats_subj_dir/X.jpg	\
		-x1D_uncensored $stats_subj_dir/X.nocensor.xmat.1D					\
		-bucket $stats_subj_dir/stat.$subj
	3dAFNItoNIFTI -prefix $stats_subj_dir/stat.$subj.nii.gz $stats_subj_dir/stat.$subj+tlrc

	echo "subject $subj completed"
	rm $temp_v1 $temp_i1 $temp_v2 $temp_i2
end
