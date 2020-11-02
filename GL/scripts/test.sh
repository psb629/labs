#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
set subj = GL03

set root_dir = /Volumes/T7SSD1/GL
set fmri_dir = $root_dir/fMRI_data
set roi_dir = $root_dir/roi
set reg_dir = $root_dir/behav_data/regressors
set output_dir = $root_dir/ppi

set sd = M1
set TR = 2
set n_tp = (310 300 300)

cd $output_dir
foreach cc (`count -digits 2 1 3`)
	3dmaskave -mask $roi_dir/mask.M1.nii.gz -quiet $fmri_dir/$subj/pb04.$subj.r$cc.scale+tlrc >Seed.$subj.r$cc.$sd.1D
	1dtranspose Seed.$subj.r$cc.$sd.1D >temp1.1D
	3dDetrend -polort 5 -prefix SeedR.$subj.r$cc.$sd.1D temp1.1D
	1dtranspose SeedR.$subj.r$cc.$sd.1D >temp2.1D
	1dUpsample 2 temp2.1D >Seed_ts.$subj.r$cc.$sd.1D
	# -FALTUNG fset prefix pen fac
	3dTfitter -RHS Seed_ts.$subj.r$cc.$sd.1D -FALTUNG $root_dir/GammaHR.1D temp3.1D 012 -1
	1dtranspose temp3.1D Seed_neur.$subj.r$cc.$sd.1D
	#head -$cc $reg_dir/${subj}_onsettime_r$cc.txt | tail -1 >temp.1D
	rm ./SeedR.$subj.r$cc.$sd.1D ./temp?.1D
end
cat Seed_ts.$subj.r??.$sd.1D >Seed_ts.$subj.$sd.1D
cat Seed_neur.$subj.r??.$sd.1D >Seed_neur.$subj.$sd.1D
#1deval -a Seed_neur.$subj.$sd.1D -b $rootdir/cond_binary/{$subj}_binary_pri.txt -expr 'a*b' >$rootdir/text_data/Inter_neur.$subj.primacy.$mask.1D
