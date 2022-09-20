#!/bin/tcsh

if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = GL03
endif

## Source file
set dir_preproc = /mnt/sda2/GL/fmri_data/$subj/preprocessed

## set regressor
set dir_reg = /home/sungbeenpark/Github/labs/GL/behav_data/regressors/MoveStop

## assign output directory name
set dir_output = /mnt/ext6/GL/fmri_data/stats/GLM.Move-Stop.SSKim/$subj
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif

## enter the results directory (can begin processing data)
cd $dir_output

3dDeconvolve -input $dir_preproc/pb04.$subj.r01.scale+tlrc.HEAD \
	-mask $dir_preproc/full_mask.$subj+tlrc \
	-censor $dir_preproc/motion_$subj.r01_censor.1D \
	-polort A -float -local_times \
	-num_stimts 8 \
	-num_glt 3 \
	-stim_times_AM1 1 $dir_reg/${subj}_Move.txt dmBLOCK \
	-stim_label 1 Move \
	-stim_times_AM1 2 $dir_reg/${subj}_Stop.txt dmBLOCK \
	-stim_label 2 Stop \
	-stim_file 3 "$dir_preproc/motion_demean.$subj.r02_07.1D[0]" -stim_base 3 -stim_label 3 roll \
	-stim_file 4 "$dir_preproc/motion_demean.$subj.r02_07.1D[1]" -stim_base 4 -stim_label 4 pitch \
	-stim_file 5 "$dir_preproc/motion_demean.$subj.r02_07.1D[2]" -stim_base 5 -stim_label 5 yaw \
	-stim_file 6 "$dir_preproc/motion_demean.$subj.r02_07.1D[3]" -stim_base 6 -stim_label 6 dS \
	-stim_file 7 "$dir_preproc/motion_demean.$subj.r02_07.1D[4]" -stim_base 7 -stim_label 7 dL \
	-stim_file 8 "$dir_preproc/motion_demean.$subj.r02_07.1D[5]" -stim_base 8 -stim_label 8 dP \
	-gltsym 'SYM: Move' -glt_label 1 Move \
	-gltsym 'SYM: Stop' -glt_label 2 Stop \
	-gltsym 'SYM: Move -Stop' -glt_label 3 Move-Stop \
	-fout -tout -x1D X.xmat.1D -xjpeg X.jpg -x1D_uncensored X.nocensor.xmat.1D \
	-bucket statMove.$subj

