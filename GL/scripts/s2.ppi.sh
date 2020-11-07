#!/bin/tcsh

set root_dir = /Volumes/T7SSD1/GL
set output_dir = $root_dir/ppi
set fan_dir = $root_dir/roi/fan280
set mask_list = (M1 S1)
set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

# there are 3 runs
set runs = `count -digits 2 1 3`
# number of time points per run in TR
set n_tp = 480
set TR = 2
# up-sample the data because of stimulus duration of 3s
set sub_TR = 1
# three conditions
set condList = (A B C)

set subj = GL$subj_list[1]
# seed label
set sd = $mask_list[1]
# create Gamma impulse response function
waver -dt $TR -GAM -peak 1 -inline 1@1 > $root_dir/GammaHR.1D

set data_dir = $root_dir/fMRI_data/$subj
# for each run, extract seed time series, run deconvolution, and create interaction regressor
foreach cc ($runs)
	3dmaskave -mask ROI+orig -quiet $data_dir/pb04.$subj.r${cc}.scale+tlrc > $output_dir/Seed${cc}${sd}.1D
	# 2| Remove the trend from the seed time series. Note: 3dDetrend only takes rows as input, 
	# so if you have an input file with a column in Seed.1D, add \' to "Seed.1D":
	# 3dDetrend -polort ? -prefix SeedR Seed.1D\'
	3dDetrend -polort 2 -prefix SeedR${cc}${sd} Seed${cc}${sd}.1D
	# The output SeedR.1D is a one-row text file. Convert the one-row time series to one column:
	1dtranspose SeedR${cc}${sd}.1D Seed_ts${cc}${sd}D.1D
	rm -f SeedR${cc}${sd}.1D
	# 2a| If your stimulus onset times were not synchronized with TR grids, pick up a sub_TR,
	# e.g., 0.1 seconds, replace the above 1dtranspose step and upsample seed time series by xx (original TR divided by sub_TR) times:
	1dUpsample 2 Seed_ts${cc}${sd}D.1D > Seed_ts${cc}${sd}.1D
	# 3| Run deconvolution on the seed time series
	3dTfitter -RHS Seed_ts${cc}${sd}.1D -FALTUNG GammaHR.1D Seed_Neur${cc}${sd} 012 -1
	
	foreach cond ($condList)
		# 3a| In case your stimulus onset times were not synchronized with TR grids, replace the above waver command with
		head -${cc} stimuli/Allruns_stim_${cond}_time.1D |tail -1 > tmp.1D
		waver -dt ${sub_TR} -FILE ${sub_TR} one1.1D -tstim `cat tmp.1D` -numout ${n_tp} > ${cond}${cc}${sd}.1D
		rm -f tmp.1D
		# 4| Obtain the interaction regressor
		1deval -a Seed_Neur${cc}${sd}.1D\' -b ${cond}${cc}${sd}.1D -expr 'a*b' > Inter_neu${cond}${cc}${sd}.1D
		waver -GAM -peak 1 -${TR} ${sub_TR} -input Inter_neu${cond}${cc}${sd}.1D -numout ${n_tp} > Inter_hrf${cond}${cc}${sd}.1D
		# 4a| If your stimulus onset times were not synchronized with TR grids, 
		# for each condition you can obtain the 1s (condition present) and 0s (condition absent) with the following command:
		# timing_tool.py -timing condition_timing_in_original_TR -tr sub_TR -stim_dur ... -run_len ... -min_frac ... -timing_to_1D ... -per_run -show_timing
		# And in the end you may need to down-sample the interaction time series back to TR grids by running
		1dcat Inter_hrf${cond}${cc}${sd}.1D'{0..$(2)}' > Inter_ts${cond}${cc}${sd}.1D
	end
end

# catenate the two regressors across runs
cat Seed_ts?${sd}D.1D > Seed_ts${sd}.1D
cat Inter_ts${cond}?${sd}.1D > Inter_ts${cond}${sd}.1D

# re-run regression analysis by adding the two new regressors
3dDeconvolve -input pb04.$subj.r??.scale+tlrc.HEAD \
-polort A \
-mask full_mask.$subj+orig \
-num_stimts 13 \
-stim_times 1 stimuli/Allruns_stim_A_time.1D 'BLOCK(3,1)' \
-stim_label 1 A \
-stim_times 2 stimuli/Allruns_stim_B_time.1D 'BLOCK(3,1)' \
-stim_label 2 B \
-stim_times 3 stimuli/Allruns_stim_C_time.1D 'BLOCK(3,1)' \
-stim_label 3 C \
-stim_file 4 dfile.rall.1D'[0]' -stim_base 4 -stim_label 6 roll \
-stim_file 5 dfile.rall.1D'[1]' -stim_base 5 -stim_label 7 pitch \
-stim_file 6 dfile.rall.1D'[2]' -stim_base 6 -stim_label 8 yaw \
-stim_file 7 dfile.rall.1D'[3]' -stim_base 7 -stim_label 9 dS \
-stim_file 8 dfile.rall.1D'[4]' -stim_base 8 -stim_label 10 dL \
-stim_file 9 dfile.rall.1D'[5]' -stim_base 9 -stim_label 11 dP \
-stim_file 10 Seed_ts${sd}.1D -stim_label 10 Seed \
-stim_file 11 Inter_tsA${sd}.1D -stim_label 11 PPIA \
-stim_file 12 Inter_tsB${sd}.1D -stim_label 12 PPIB \
-stim_file 13 Inter_tsC${sd}.1D -stim_label 13 PPIC \
-rout -tout \
-bucket PPIstat${sd}
