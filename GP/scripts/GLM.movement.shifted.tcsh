#!/bin/tcsh -xef

if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = "invalid"
endif

set dir_root = /mnt/ext6/GP 

set dir_t1 = $dir_root/fmri_data/preproc_data/$subj/day1/preprocessed
set dir_epi = $dir_root/fmri_data/preproc_data/$subj/day2/preprocessed

set stat = '2.5s_shifted'
set dir_reg = $dir_root/behav_data/regressors/AM/$stat

# assign output directory name
set dir_output = $dir_root/fmri_data/stats/GLM.movement.$stat/$subj
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif
# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $dir_output

# ------------------------------
## 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )

3dDeconvolve -input $dir_epi/pb04.$subj.r01.scale+tlrc.HEAD $dir_epi/pb04.$subj.r02.scale+tlrc.HEAD $dir_epi/pb04.$subj.r03.scale+tlrc.HEAD \
	-mask $dir_epi/full_mask.$subj+tlrc \
	-censor $dir_epi/motion_${subj}_censor.1D \
    -ortvec $dir_epi/motion_demean.$subj.1D mot_demean \
	-polort A -float -local_times \
	-num_stimts 1 \
	-stim_times_AM2 1 $dir_reg/${subj}_movement.1D 'BLOCK(1,1)' -stim_label 1 Length \
	-num_glt 1 \
	-gltsym 'SYM: Length' -glt_label 1 Length \
	-fout -tout -x1D X.xmat.1D -xjpeg X.jpg -x1D_uncensored X.nocensor.xmat.1D \
	-bucket stats.$subj

echo "execution finished: `date`"
