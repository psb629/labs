#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
set subj = GL${subj_list[1]}

set root_dir = /Volumes/T7SSD1/GL
set fmri_dir = $root_dir/fMRI_data
set roi_dir = $root_dir/roi
set reg_dir = $root_dir/behav_data/regressors
set output_dir = $root_dir/ppi

# seed label
set roi_list = (M1 S1)
set sd = $roi_list[1]
# original TR
set TR = 2
# up-sample the data because of stimulus duration 4s(feedback or none feedback)
set sub_TR = 1
set nn = 2	# nn = TR/sub_TR
# number of pictures taken.
set n_tp = 300
# two conditions
set cond_list = (FB nFB)

# create Gamma impulse response function
if ( ! -e $root_dir/GammaHR_TR$sub_TR.1D ) then
	waver -dt $sub_TR -GAM -peak 1 -inline 1@1 >$root_dir/GammaHR_TR$sub_TR.1D
endif

cd $output_dir
foreach cc (`count -digits 2 1 4`)
	# preprocessed pb04.r01: resting state(310 pts), pb04.r02-r05: main tasks r01-r04(300 pts), pb04.r06-07(300 pts): test section on a different path
	@ xx = $cc + 1
	set xx = `printf '%02d' $xx`
	# Extract BOLD corresponding to the ROI
	3dmaskave -mask $roi_dir/mask.M1.nii.gz -quiet $fmri_dir/$subj/pb04.$subj.r$xx.scale+tlrc >Seed.$subj.r$cc.$sd.1D
	1dtranspose Seed.$subj.r$cc.$sd.1D >temp1.1D # Transpose
	# Remove the trend from the seed time series
	3dDetrend -polort 5 -prefix SeedR.$subj.r$cc.$sd.1D temp1.1D
	1dtranspose SeedR.$subj.r$cc.$sd.1D >temp2.1D # Transpose
	# replace the above 1dtranspose step and upsample seed time series by nn (original TR divided by sub_TR) times:
	1dUpsample $nn temp2.1D >Seed_ts.$subj.r$cc.$sd.1D
	# Conduct deconvolution of the seed time series which derive neuronal response from BOLD response.
	# option: -FALTUNG fset prefix penalty factor
	3dTfitter -RHS Seed_ts.$subj.r$cc.$sd.1D -FALTUNG $root_dir/GammaHR_TR$sub_TR.1D temp3.1D 012 -1
	1dtranspose temp3.1D Seed_neur.$subj.r$cc.$sd.1D # Transpose
	#head -$cc $reg_dir/${subj}_onsettime_r$cc.txt | tail -1 >temp.1D
	rm ./SeedR.$subj.r$cc.$sd.1D ./temp?.1D
	foreach cond ($cond_list)
		# In case your stimulus onset times were not synchronized with TR grids, replace the above waver command with
		# Read discrete onset times:
		head -${cc} $reg_dir/${subj}_${cond}.txt |tail -1 >temp.1D
		# up-sampling?
		#waver -dt ${sub_TR} -FILE ${sub_TR} one1.1D -tstim `cat temp.1D` -numout $n_tp >${cond}${cc}${sd}.1D
		#rm temp.1D
		# Measure interaction regressor
		#1deval -a Seed_neur.$subj.r${cc}.${sd}.1D -b ${cond}${cc}${sd}.1D -expr 'a*b' >Inter_neu.$subj.${cond}.r${cc}.${sd}.1D
		1deval -a Seed_neur.$subj.r${cc}.${sd}.1D -b temp.1D -expr 'a*b' >Inter_neu.$subj.${cond}.r${cc}.${sd}.1D
		# Create interaction
		waver -GAM -peak 1 -${TR} ${sub_TR} -input Inter_neu.$subj.${cond}.r${cc}.${sd}.1D -numout ${n_tp} >Inter_hrf.$subj.${cond}.r${cc}.${sd}.1D
		# Down-sample the interaction time series back to TR grids by running
		#1dcat Inter_hrf.$subj.${cond}.r${cc}.${sd}.1D'{0..$(2)}' >Inter_ts.$subj.${cond}.r${cc}.${sd}.1D
	end
end
# catenate the two regressors across runs:
cat Seed_ts.$subj.r??.$sd.1D >Seed_ts.$subj.$sd.1D
cat Seed_neur.$subj.r??.$sd.1D >Seed_neur.$subj.$sd.1D

# re-run regression analysis by adding the two new regressors:
3dDeconvolve -input $fmri_dir/$subj/pb04.$subj.r??.scale+tlrc.HEAD \
				 -polort A -mask $roi_dir/full/full_mask.$subj.nii.gz \
				 -num_stimts 2+6+3 \
				 -stim_times 1 $reg_dir/${subj}_FB.1D 'dmBLOCK' -stim_labe FB \
				 -stim_times 2 $reg_dir/${subj}_nFB.1D 'dmBLOCK' -stim_labe nFB \
				 -stim_file 3 $fmri_dir/$subj/"motion_demean.$subj.$run.1D[0]" -stim_base 2 -stim_label 2 roll \
				 -stim_file 4 $fmri_dir/$subj/"motion_demean.$subj.$run.1D[1]" -stim_base 3 -stim_label 3 pitch \
				 -stim_file 5 $fmri_dir/$subj/"motion_demean.$subj.$run.1D[2]" -stim_base 4 -stim_label 4 yaw \
				 -stim_file 6 $fmri_dir/$subj/"motion_demean.$subj.$run.1D[3]" -stim_base 5 -stim_label 5 dS \
				 -stim_file 7 $fmri_dir/$subj/"motion_demean.$subj.$run.1D[4]" -stim_base 6 -stim_label 6 dL \
				 -stim_file 8 $fmri_dir/$subj/"motion_demean.$subj.$run.1D[5]" -stim_base 7 -stim_label 7 dP \
				 -stim_file 11 $output_dir/Seed_ts.$subj.$sd.1D -stim_label 11 seed \
				 -stim_file 12 $output_dir/Inter_neur.$subj.FB.$mask.1D -stim_label 12 ppi_FB\
				 -stim_file 13 $output_dir/Inter_neur.$subj.nFB.$mask.1D -stim_label 13 ppi_nFB \
				 -num_glt 1 \
				 -gltsym "SYM: ppi_FB -ppi_nFB" \
				 -glt_label ppiFB_ppinFB  \
				 -rout -tout -x1D $output_dir/X.xmat.$subj.$mask.1D -x1D_uncensored $output_dir/Xuc.xmat.$subj.$mask.1D \
				 -bucket $output_dir/PPIstat.$subj.$mask

