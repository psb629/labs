#!/bin/tcsh -xef

if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = GL03
endif

set coord = 'tlrc'
set dir_preproc = /mnt/ext6/GL/fmri_data/preproc_data/$subj/$coord

set stat = '0s_shifted'
set dir_reg = /home/sungbeenpark/Github/labs/GL/behav_data/regressors/Reward.$stat

# assign output directory name
set dir_output = /mnt/ext6/GL/fmri_data/stats/GLM.reward.$stat/$subj
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
3dDeconvolve -input $dir_preproc/pb05.$subj.r01.scale+$coord.HEAD $dir_preproc/pb05.$subj.r02.scale+$coord.HEAD $dir_preproc/pb05.$subj.r03.scale+$coord.HEAD $dir_preproc/pb05.$subj.r04.scale+$coord.HEAD $dir_preproc/pb05.$subj.r05.scale+$coord.HEAD $dir_preproc/pb05.$subj.r06.scale+$coord.HEAD\
    -censor $dir_preproc/censor_${subj}_combined_2.1D				\
	-mask $dir_preproc/full_mask.$subj+$coord						\
    -ortvec $dir_preproc/mot_demean.r01.1D mot_demean_r01			\
    -ortvec $dir_preproc/mot_demean.r02.1D mot_demean_r02			\
    -ortvec $dir_preproc/mot_demean.r03.1D mot_demean_r03			\
    -ortvec $dir_preproc/mot_demean.r04.1D mot_demean_r04			\
    -ortvec $dir_preproc/mot_demean.r05.1D mot_demean_r05			\
    -ortvec $dir_preproc/mot_demean.r06.1D mot_demean_r06			\
    -ortvec $dir_preproc/mot_deriv.r01.1D mot_deriv_r01				\
    -ortvec $dir_preproc/mot_deriv.r02.1D mot_deriv_r02				\
    -ortvec $dir_preproc/mot_deriv.r03.1D mot_deriv_r03				\
    -ortvec $dir_preproc/mot_deriv.r04.1D mot_deriv_r04				\
    -ortvec $dir_preproc/mot_deriv.r05.1D mot_deriv_r05				\
    -ortvec $dir_preproc/mot_deriv.r06.1D mot_deriv_r06				\
    -polort A														\
    -num_stimts 1													\
    -stim_times_AM2 1 $dir_reg/${subj}_reward.txt 'BLOCK(1,1)'	-stim_label 1 Rew \
	-jobs 4															\
	-num_glt 1														\
    -gltsym 'SYM: Rew' -glt_label 1 Rew								\
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg							\
    -x1D_uncensored X.nocensor.xmat.1D								\
    -fitts fitts.$subj												\
    -errts errts.$subj												\
    -bucket stats.$subj

 #3dDeconvolve -input pb04.GL03.r01.scale+tlrc.HEAD \
 #	-mask full_mask.GL03+tlrc \
 #	-censor motion_GL03.r01_censor.1D \
 #	-polort A -float -local_times \
 #	-num_stimts 8 \
 #	-stim_times_AM1 1 /Users/sskim/Documents/Research/AFNI/GL/data/GL03/regressors/GL03_Move.txt dmBLOCK -stim_label 1 Move \
 #	-stim_times_AM1 2 /Users/sskim/Documents/Research/AFNI/GL/data/GL03/regressors/GL03_Stop.txt dmBLOCK -stim_label 2 Stop \
 #	-stim_file 3 'motion_demean.GL03.r01.1D[0]' -stim_base 3 -stim_label 3 roll \
 #	-stim_file 4 'motion_demean.GL03.r01.1D[1]' -stim_base 4 -stim_label 4 pitch \
 #	-stim_file 5 'motion_demean.GL03.r01.1D[2]' -stim_base 5 -stim_label 5 yaw \
 #	-stim_file 6 'motion_demean.GL03.r01.1D[3]' -stim_base 6 -stim_label 6 dS \
 #	-stim_file 7 'motion_demean.GL03.r01.1D[4]' -stim_base 7 -stim_label 7 dL \
 #	-stim_file 8 'motion_demean.GL03.r01.1D[5]' -stim_base 8 -stim_label 8 dP \
 #	-num_glt 3 \
 #	-gltsym 'SYM: Move' -glt_label 1 Move -gltsym 'SYM: Stop' \
 #	-glt_label 2 Stop -gltsym 'SYM: Move -Stop' -glt_label 3 Move-Stop \
 #	-fout -tout \
 #	-x1D X.xmat.1D -xjpeg X.jpg -x1D_uncensored X.nocensor.xmat.1D \
 #	-bucket /Users/sskim/Documents/Research/AFNI/GL/data/GL03/stats/statMove.GL03

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
