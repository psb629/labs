#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
set subj = GL${subj_list[1]}

set root_dir = /Volumes/T7SSD1/GL
set fmri_dir = $root_dir/fMRI_data
set roi_dir = $root_dir/roi
set reg_dir = $root_dir/behav_data/regressors
set output_dir = $root_dir/ppi

# seed label
set sd = M1
# original TR
set TR = 2
# up-sample the data because of stimulus duration 5s(feedback/none feedback)
set sub_TR = 1
# number of pictures taken.
set n_tp = 300
# two conditions
set cond_list = (FB nFB)

# create Gamma impulse response function
if ( ! $root_dir/GammaHR_TR$sub_TR.1D  -e ) then
	waver -dt $sub_TR -GAM -peak 1 -inline 1@1 >$root_dir/GammaHR_TR$sub_TR.1D
endif

cd $output_dir
foreach cc (`count -digits 2 1 3`)
	3dmaskave -mask $roi_dir/mask.M1.nii.gz -quiet $fmri_dir/$subj/pb04.$subj.r$cc.scale+tlrc >Seed.$subj.r$cc.$sd.1D
	1dtranspose Seed.$subj.r$cc.$sd.1D >temp1.1D
	3dDetrend -polort 5 -prefix SeedR.$subj.r$cc.$sd.1D temp1.1D
	1dtranspose SeedR.$subj.r$cc.$sd.1D >temp2.1D
	# replace the above 1dtranspose step and upsample seed time series by xx (original TR divided by sub_TR) times:
	1dUpsample 2 temp2.1D >Seed_ts.$subj.r$cc.$sd.1D
	# -FALTUNG fset prefix penalty factor : Deconvolution
	3dTfitter -RHS Seed_ts.$subj.r$cc.$sd.1D -FALTUNG $root_dir/GammaHR_TR$sub_TR.1D temp3.1D 012 -1
	1dtranspose temp3.1D Seed_neur.$subj.r$cc.$sd.1D
	#head -$cc $reg_dir/${subj}_onsettime_r$cc.txt | tail -1 >temp.1D
	rm ./SeedR.$subj.r$cc.$sd.1D ./temp?.1D
	foreach cond ($cond_list)
		# In case your stimulus onset times were not synchronized with TR grids, replace the above waver command with
		# Read discrete onset times:
		head -${cc} $reg_dir/${subj}_Rew.txt |tail -1 >temp.1D
		# convolve the waveform with delta-functions at those time:
		waver -dt ${sub_TR} -FILE ${sub_TR} one1.1D -tstim `cat temp.1D` -numout $n_tp >${cond}${cc}${sd}.1D
		rm temp.1D
		# Obtain the interaction regressor
		1deval -a Seed_neur.$subj.r${cc}.${sd}.1D -b ${cond}${cc}${sd}.1D -expr 'a*b' >Inter_neu.$subj.${cond}.r${cc}.${sd}.1D
		waver -GAM -peak 1 -${TR} ${sub_TR} -input Inter_neu.$subj.${cond}.r${cc}.${sd}.1D -numout ${n_tp} >Inter_hrf.$subj.${cond}.r${cc}.${sd}.1D
		# In the end you may need to down-sample the interaction time series back to TR grids by running
		1dcat Inter_hrf.$subj.${cond}.r${cc}.${sd}.1D'{0..$(2)}' >Inter_ts.$subj.${cond}.r${cc}.${sd}.1D
	end
end
# catenate the two regressors across runs:
cat Seed_ts.$subj.r??.$sd.1D >Seed_ts.$subj.$sd.1D
cat Seed_neur.$subj.r??.$sd.1D >Seed_neur.$subj.$sd.1D

# re-run regression analysis by adding the two new regressors:
3dDeconvolve -input $fmri_dir/$subj/pb04.$subj.r??.scale+tlrc.HEAD \
				 -polort A -mask $roi_dir/full/full_mask.$subj.nii.gz \
				 -num_stimts 2+6+3 \
				 -stim_times 1 temp.1D 'BLOCK(60,1)' -stim_labe FB \
				 -stim_times 2 temp.1D 'BLOCK(60,1)' -stim_labe nFB \
				 -stim_file 3 "motion_demean.$subj.$run.1D[0]" -stim_base 2 -stim_label 2 roll \
				 -stim_file 4 "motion_demean.$subj.$run.1D[1]" -stim_base 3 -stim_label 3 pitch \
				 -stim_file 5 "motion_demean.$subj.$run.1D[2]" -stim_base 4 -stim_label 4 yaw \
				 -stim_file 6 "motion_demean.$subj.$run.1D[3]" -stim_base 5 -stim_label 5 dS \
				 -stim_file 7 "motion_demean.$subj.$run.1D[4]" -stim_base 6 -stim_label 6 dL \
				 -stim_file 8 "motion_demean.$subj.$run.1D[5]" -stim_base 7 -stim_label 7 dP \
				 -stim_file 11 $rootdir/text_data/ppi_seed_ts.$subj.$mask.1D -stim_label 11 seed \
				 -stim_file 12 $rootdir/text_data/Inter_neur.$subj.FB.$mask.1D -stim_label 12 PPI_FB\
				 -stim_file 13 $rootdir/text_data/Inter_neur.$subj.nFB.$mask.1D -stim_label 13 PPI_nFB \
				 -rout -tout -x1D $rootdir/ppi_results/X.xmat.$subj.$mask.1D -x1D_uncensored $rootdir/ppi_results/Xuc.xmat.$subj.$mask.1D \
				 -bucket $rootdir/ppi_results/PPIstat.$subj.$mask

