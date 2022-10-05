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
set dir_output = $dir_root/fmri_data/stats/GLM.reward.$stat/$subj
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif
# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $dir_output

# ------------------------------
## 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
# run the regression analysis
 #3dDeconvolve -input $dir_preproc/pb05.$subj.r01.scale+$coord.HEAD $dir_preproc/pb05.$subj.r02.scale+$coord.HEAD $dir_preproc/pb05.$subj.r03.scale+$coord.HEAD $dir_preproc/pb05.$subj.r04.scale+$coord.HEAD $dir_preproc/pb05.$subj.r05.scale+$coord.HEAD $dir_preproc/pb05.$subj.r06.scale+$coord.HEAD\
 #    -censor $dir_preproc/censor_${subj}_combined_2.1D				\
 #	-mask $dir_preproc/full_mask.$subj+$coord						\
 #    -ortvec $dir_preproc/mot_demean.r01.1D mot_demean_r01			\
 #    -ortvec $dir_preproc/mot_demean.r02.1D mot_demean_r02			\
 #    -ortvec $dir_preproc/mot_demean.r03.1D mot_demean_r03			\
 #    -ortvec $dir_preproc/mot_demean.r04.1D mot_demean_r04			\
 #    -ortvec $dir_preproc/mot_demean.r05.1D mot_demean_r05			\
 #    -ortvec $dir_preproc/mot_demean.r06.1D mot_demean_r06			\
 #    -polort A														\
 #    -num_stimts 1													\
 #    -stim_times_AM2 1 $dir_reg/${subj}_reward.txt 'BLOCK(1,1)'	-stim_label 1 Rew \
 #	-jobs 4															\
 #	-num_glt 1														\
 #    -gltsym 'SYM: Rew' -glt_label 1 Rew								\
 #    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg							\
 #    -x1D_uncensored X.nocensor.xmat.1D								\
 #    -fitts fitts.$subj												\
 #    -errts errts.$subj												\
 #    -bucket stats.$subj

3dDeconvolve -input $dir_epi/pb04.$subj.r01.scale+tlrc.HEAD $dir_epi/pb04.$subj.r02.scale+tlrc.HEAD $dir_epi/pb04.$subj.r03.scale+tlrc.HEAD \
	-mask $dir_epi/full_mask.$subj+tlrc \
	-censor $dir_epi/motion_${subj}_censor.1D \
    -ortvec $dir_epi/motion_demean.$subj.1D mot_demean \
	-polort A -float -local_times \
	-num_stimts 1 \
	-stim_times_AM2 1 $dir_reg/${subj}_reward.txt 'BLOCK(1,1)' -stim_label 1 Rew \
	-num_glt 1 \
	-gltsym 'SYM: Rew' -glt_label 1 Rew \
	-fout -tout -x1D X.xmat.1D -xjpeg X.jpg -x1D_uncensored X.nocensor.xmat.1D \
	-bucket stats.$subj

echo "execution finished: `date`"
