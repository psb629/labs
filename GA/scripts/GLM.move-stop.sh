#!/bin/tcsh

set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
# set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)
# outliers : GD29, GD31
# No data : GD19
set dname = GLM.move-stop
# ============================================================
set data_dir = /Volumes/clmnlab/GA/fmri_data/preproc_data

set root_dir = /Volumes/T7SSD1/GA
set behav_dir = $root_dir/behav_data
set reg_dir = $behav_dir/regressors/move-stop
set fmri_dir = $root_dir/fMRI_data
set roi_dir = $fmri_dir/roi
set stats_dir = $fmri_dir/stats
 ## ============================================================
 #foreach nn ($subj_list)
 #	## check the existence
 #	set temp = $data_dir
 #	if (! -d $temp) then
 #		echo "need to make $temp's regressors first!"
 #		continue
 #	endif
 #	## make output directory
 #	set output_dir = $stats_dir/$dname/$nn
 #	if (! -d $output_dir) then
 #		mkdir -p -m 755 $output_dir
 #	endif
 #	# ============================================================
 #	cd $output_dir
 #	# 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
 #	3dDeconvolve -input $data_dir/GA$nn/pb04.GA$nn.r00.scale+tlrc \
 #			 -mask $roi_dir/full/full_mask.GA$nn.nii.gz \
 #			 -censor $fmri_dir/preproc_data/$nn/motion_censor.GA$nn.r00.1D \
 #			 -polort A -float \
 #			 -local_times \
 #			 -num_stimts 8 \
 #			 -num_glt 1 \
 #			 -stim_times_AM1 1 $reg_dir/${nn}_Move.txt dmBLOCK \
 #			 -stim_label 1 Move \
 #			 -stim_times_AM1 2 $reg_dir/${nn}_Stop.txt dmBLOCK \
 #			 -stim_label 2 Stop \
 #			 -stim_file 3 "$fmri_dir/preproc_data/$nn/motion_demean.GA$nn.r00.1D[0]" -stim_base 3 -stim_label 3 roll \
 #			 -stim_file 4 "$fmri_dir/preproc_data/$nn/motion_demean.GA$nn.r00.1D[1]" -stim_base 4 -stim_label 4 pitch \
 #			 -stim_file 5 "$fmri_dir/preproc_data/$nn/motion_demean.GA$nn.r00.1D[2]" -stim_base 5 -stim_label 5 yaw \
 #			 -stim_file 6 "$fmri_dir/preproc_data/$nn/motion_demean.GA$nn.r00.1D[3]" -stim_base 6 -stim_label 6 dS \
 #			 -stim_file 7 "$fmri_dir/preproc_data/$nn/motion_demean.GA$nn.r00.1D[4]" -stim_base 7 -stim_label 7 dL \
 #			 -stim_file 8 "$fmri_dir/preproc_data/$nn/motion_demean.GA$nn.r00.1D[5]" -stim_base 8 -stim_label 8 dP \
 #			 -gltsym 'SYM: Move -Stop' \
 #			 -glt_label 1 Move-Stop \
 #			 -jobs 4 -fout -tout \
 #			 -x1D ./X.statMove.xmat.1D \
 #			 -xjpeg ./X.statMove.jpg \
 #			 -x1D_uncensored ./X.statMove.nocensor.xmat.1D \
 #			 -bucket ./statMove.$nn
 #	# ============================================================
 #	3dAFNItoNIFTI -prefix $output_dir/statMove.$nn.nii.gz $output_dir/statMove.$nn+tlrc.
 #	# ============================================================
 # #	gzip -1v $output_dir/*.BRIK
 #	rm $output_dir/statMove.$nn+tlrc.*
 #	# ============================================================
 #	echo "subject GA$nn completed"
 #end
# ============================================================
## group t-test
set output_dir = $stats_dir/$dname
set group_dir = $output_dir/group
if ( ! -d $group_dir ) then
	mkdir -p -m 755 $group_dir
endif

set temp = ()
foreach nn ($subj_list)
	3dcalc -a $output_dir/$nn/"statMove.$nn.nii.gz[7]" -expr "a" -prefix $group_dir/temp.$nn.nii.gz
	set temp = ($temp $group_dir/temp.$nn.nii.gz)
end

set gmask = $roi_dir/full_mask.GAs.nii.gz
set pname = $output_dir/group.statMove.nii.gz
3dttest++ -mask $gmask -setA $temp -prefix $pname
rm -r $group_dir
# ============================================================
