#!/bin/tcsh -xef

if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = GL03
endif

set coord = 'tlrc'

set dir_preproc = /mnt/sdb2/GL/fmri_data/preproc_data/$subj/$coord
set dir_reg = /mnt/sda2/GL/behav_data/regressors

# assign output directory name
set dir_output = /mnt/sdb2/GL/fmri_data/stats/GLM.reward/$subj
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif
cp -n $dir_preproc/anat_final.$subj+$coord.* $dir_output
# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $dir_output

# ------------------------------
## 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
# run the regression analysis
3dDeconvolve -input $dir_preproc/pb05.$subj.r*.scale+$coord.HEAD	\
    -censor $dir_preproc/censor_${subj}_combined_2.1D				\
	-mask $dir_preproc/full_mask.$subj+$coord						\
    -ortvec $dir_preproc/mot_demean.r01.1D mot_demean_r01			\
    -ortvec $dir_preproc/mot_demean.r02.1D mot_demean_r02			\
    -ortvec $dir_preproc/mot_demean.r03.1D mot_demean_r03			\
    -ortvec $dir_preproc/mot_demean.r04.1D mot_demean_r04			\
    -ortvec $dir_preproc/mot_deriv.r01.1D mot_deriv_r01				\
    -ortvec $dir_preproc/mot_deriv.r02.1D mot_deriv_r02				\
    -ortvec $dir_preproc/mot_deriv.r03.1D mot_deriv_r03				\
    -ortvec $dir_preproc/mot_deriv.r04.1D mot_deriv_r04				\
    -polort 4														\
    -num_stimts 1													\
    -stim_times_AM2 1 $dir_reg/${subj}_Rew.txt 'BLOCK(1,1)'	-stim_label 1 Rew	\
	-jobs 1															\
	-num_glt 1														\
    -gltsym 'SYM: Rew' -glt_label 1 Rew								\
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg							\
    -x1D_uncensored X.nocensor.xmat.1D								\
    -fitts fitts.$subj												\
    -errts errts.${subj}											\
    -bucket stats.$subj

 #3dDeconvolve -input $dir_preproc/pb05.$subj.r*.scale+$coord.HEAD	\
 #    -censor $dir_preproc/censor_${subj}_combined_2.1D				\
 #	-mask $dir_preproc/full_mask.$subj+$coord						\
 # #    -ortvec $dir_preproc/bandpass_rall.1D bandpass				\
 #    -ortvec $dir_preproc/mot_demean.r01.1D mot_demean_r01			\
 #    -ortvec $dir_preproc/mot_demean.r02.1D mot_demean_r02			\
 #    -ortvec $dir_preproc/mot_demean.r03.1D mot_demean_r03			\
 #    -ortvec $dir_preproc/mot_demean.r04.1D mot_demean_r04			\
 #    -ortvec $dir_preproc/mot_deriv.r01.1D mot_deriv_r01				\
 #    -ortvec $dir_preproc/mot_deriv.r02.1D mot_deriv_r02				\
 #    -ortvec $dir_preproc/mot_deriv.r03.1D mot_deriv_r03				\
 #    -ortvec $dir_preproc/mot_deriv.r04.1D mot_deriv_r04				\
 #    -polort 4														\
 # #    -num_stimts 2													\
 # #    -stim_times_AM2 1 $dir_preproc/stimuli/${subj}_RewFB.txt 'BLOCK(1,1)'	\
 # #    -stim_label 1 RewFB												\
 # #    -stim_times_AM2 2 $dir_preproc/stimuli/${subj}_RewnFB.txt 'BLOCK(1,1)'	\
 # #    -stim_label 2 RewnFB											\
 #    -num_stimts 1													\
 #    -stim_times_AM2 1 $dir_preproc/stimuli/${subj}_Rew.txt 'BLOCK(1,1)'	-stim_label 1 Rew	\
 #	-jobs 1															\
 #	-num_glt 1														\
 #    -gltsym 'SYM: Rew' -glt_label 1 Rew								\
 #    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg							\
 #    -x1D_uncensored X.nocensor.xmat.1D								\
 #    -fitts fitts.$subj												\
 #    -errts errts.${subj}											\
 #    -bucket stats.$subj

echo "execution finished: `date`"
