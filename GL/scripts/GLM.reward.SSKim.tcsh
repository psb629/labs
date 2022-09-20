#!/bin/tcsh -xef

if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = GL03
endif

set dir_preproc = /mnt/sda2/GL/fmri_data/$subj/preprocessed

set stat = '2s_shifted'
set dir_reg = /home/sungbeenpark/Github/labs/GL/behav_data/regressors/Reward.$stat

# assign output directory name
set dir_output = /mnt/ext6/GL/fmri_data/stats/GLM.reward.$stat.SSKim/$subj
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif
cp -n $dir_preproc/anat_final.$subj+tlrc.* $dir_output
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

3dDeconvolve -input $dir_preproc/pb04.$subj.r02.scale+tlrc.HEAD $dir_preproc/pb04.$subj.r03.scale+tlrc.HEAD $dir_preproc/pb04.$subj.r04.scale+tlrc.HEAD $dir_preproc/pb04.$subj.r05.scale+tlrc.HEAD $dir_preproc/pb04.$subj.r06.scale+tlrc.HEAD $dir_preproc/pb04.$subj.r07.scale+tlrc.HEAD \
	-mask $dir_preproc/full_mask.$subj+tlrc \
	-censor $dir_preproc/motion_$subj.r02_07.censor.1D \
	-polort A -float -local_times \
	-num_stimts 7 \
	-num_glt 1 -stim_times_AM2 1 $dir_reg/${subj}_reward.txt 'BLOCK(1,1)' -stim_label 1 Rew \
	-stim_file 2 "$dir_preproc/motion_demean.$subj.r02_07.1D[0]" -stim_base 2 -stim_label 2 roll \
	-stim_file 3 "$dir_preproc/motion_demean.$subj.r02_07.1D[1]" -stim_base 3 -stim_label 3 pitch \
	-stim_file 4 "$dir_preproc/motion_demean.$subj.r02_07.1D[2]" -stim_base 4 -stim_label 4 yaw \
	-stim_file 5 "$dir_preproc/motion_demean.$subj.r02_07.1D[3]" -stim_base 5 -stim_label 5 dS \
	-stim_file 6 "$dir_preproc/motion_demean.$subj.r02_07.1D[4]" -stim_base 6 -stim_label 6 dL \
	-stim_file 7 "$dir_preproc/motion_demean.$subj.r02_07.1D[5]" -stim_base 7 -stim_label 7 dP \
	-gltsym 'SYM: Rew' -glt_label 1 Rew \
	-fout -tout -x1D X.xmat.1D -xjpeg X.jpg -x1D_uncensored X.nocensor.xmat.1D \
	-bucket stats.$subj

echo "execution finished: `date`"
