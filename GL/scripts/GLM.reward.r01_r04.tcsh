#!/bin/tcsh -xef

if ( $#argv > 0 ) then
    set subj = $argv[1]
else
    set subj = GL03
endif

set coord = 'tlrc'
set dir_preproc = /mnt/sdb2/GL/fmri_data/preproc_data/$subj/$coord

# assign output directory name
set dir_output = /mnt/sdb2/GL/fmri_data/stats/GLM.reward/$subj
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif
cp -n $dir_preproc/anat_final.$subj+$coord.* $dir_output
# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $dir_output

# note TRs that were not censored
set ktrs = `1d_tool.py -infile $dir_preproc/censor_${subj}_combined_2.1D \
                       -show_trs_uncensored encoded`
# ------------------------------
# run the regression analysis
3dDeconvolve -input $dir_preproc/pb05.$subj.r01.scale+$coord.HEAD	\
    -censor $dir_preproc/censor_${subj}_combined_2.1D				\
	-mask $dir_preproc/full_mask.$subj+$coord						\
 #    -ortvec $dir_preproc/bandpass_rall.1D bandpass				\
    -ortvec $dir_preproc/mot_demean.r01.1D mot_demean_r01			\
    -ortvec $dir_preproc/mot_demean.r02.1D mot_demean_r02			\
    -ortvec $dir_preproc/mot_demean.r03.1D mot_demean_r03			\
    -ortvec $dir_preproc/mot_demean.r04.1D mot_demean_r04			\
    -ortvec $dir_preproc/mot_deriv.r01.1D mot_deriv_r01				\
    -ortvec $dir_preproc/mot_deriv.r02.1D mot_deriv_r02				\
    -ortvec $dir_preproc/mot_deriv.r03.1D mot_deriv_r03				\
    -ortvec $dir_preproc/mot_deriv.r04.1D mot_deriv_r04				\
    -polort 5														\
 #    -num_stimts 2													\
 #    -stim_times_AM2 1 $dir_preproc/stimuli/${subj}_RewFB.txt 'BLOCK(1,1)'	\
 #    -stim_label 1 RewFB												\
 #    -stim_times_AM2 2 $dir_preproc/stimuli/${subj}_RewnFB.txt 'BLOCK(1,1)'	\
 #    -stim_label 2 RewnFB											\
    -num_stimts 1													\
    -stim_times_AM2 1 $dir_preproc/stimuli/${subj}_Rew.txt 'BLOCK(1,1)'	-stim_label 1 Rew	\
	-jobs 1															\
	-num_glt 1														\
    -gltsym 'SYM: Rew' -glt_label 1 Rew								\
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg							\
    -x1D_uncensored X.nocensor.xmat.1D								\
    -fitts fitts.$subj												\
    -errts errts.${subj}											\
    -bucket stats.$subj

 ## if 3dDeconvolve fails, terminate the script
 #if ( $status != 0 ) then
 #    echo '---------------------------------------'
 #    echo '** 3dDeconvolve error, failing...'
 #    echo '   (consider the file 3dDeconvolve.err)'
 #    exit
 #endif
 #
 #
 ## display any large pairwise correlations from the X-matrix
 #1d_tool.py -show_cormat_warnings -infile X.xmat.1D |& tee out.cormat_warn.txt
 #
 ## display degrees of freedom info from X-matrix
 #1d_tool.py -show_df_info -infile X.xmat.1D |& tee out.df_info.txt
 #
 ## create an all_runs dataset to match the fitts, errts, etc.
 #3dTcat -prefix all_runs.$subj pb05.$subj.r*.scale+orig.HEAD
 #
 ## --------------------------------------------------
 ## create a temporal signal to noise ratio dataset 
 ##    signal: if 'scale' block, mean should be 100
 ##    noise : compute standard deviation of errts
 #3dTstat -mean -prefix rm.signal.all all_runs.$subj+orig"[$ktrs]"
 #3dTstat -stdev -prefix rm.noise.all errts.${subj}+orig"[$ktrs]"
 #3dcalc -a rm.signal.all+orig                                         \
 #       -b rm.noise.all+orig                                          \
 #       -expr 'a/b' -prefix TSNR.$subj
 #
 ## ---------------------------------------------------
 ## compute and store GCOR (global correlation average)
 ## (sum of squares of global mean of unit errts)
 #3dTnorm -norm2 -prefix rm.errts.unit errts.${subj}+orig
 #3dmaskave -quiet -mask full_mask.$subj+orig rm.errts.unit+orig       \
 #          > mean.errts.unit.1D
 #3dTstat -sos -prefix - mean.errts.unit.1D\' > out.gcor.1D
 #echo "-- GCOR = `cat out.gcor.1D`"
 #
 ## ---------------------------------------------------
 ## compute correlation volume
 ## (per voxel: correlation with masked brain average)
 #3dmaskave -quiet -mask full_mask.$subj+orig errts.${subj}+orig       \
 #          > mean.errts.1D
 #3dTcorr1D -prefix corr_brain errts.${subj}+orig mean.errts.1D
 #
 ## --------------------------------------------------
 ## extract non-baseline regressors from the X-matrix,
 ## then compute their sum
 #1d_tool.py -infile X.nocensor.xmat.1D -write_xstim X.stim.xmat.1D
 #3dTstat -sum -prefix sum_ideal.1D X.stim.xmat.1D
 #
 ## ================== auto block: generate review scripts ===================
 #
 ## generate a review script for the unprocessed EPI data
 #gen_epi_review.py -script @epi_review.$subj \
 #    -dsets pb00.$subj.r*.tcat+orig.HEAD
 #
 ## generate scripts to review single subject results
 ## (try with defaults, but do not allow bad exit status)
 #gen_ss_review_scripts.py -exit0             \
 #    -mot_limit 0.4 -out_limit 0.05          \
 #    -mask_dset full_mask.$subj+orig.HEAD    \
 #    -ss_review_dset out.ss_review.$subj.txt \
 #    -write_uvars_json out.ss_review_uvars.json
 #
 ## ========================== auto block: finalize ==========================
 #
 ## remove temporary files
 #\rm -f rm.*
 #
 ## if the basic subject review script is here, run it
 ## (want this to be the last text output)
 #if ( -e @ss_review_basic ) then
 #    ./@ss_review_basic |& tee out.ss_review.$subj.txt
 #
 #    # generate html ss review pages
 #    # (akin to static images from running @ss_review_driver)
 #    apqc_make_tcsh.py -review_style pythonic -subj_dir . \
 #        -uvar_json out.ss_review_uvars.json
 #    tcsh @ss_review_html |& tee out.review_html
 #    apqc_make_html.py -qc_dir QC_$subj
 #
 #    echo "\nconsider running: \n\n    afni_open -b /mnt/sdb2/GL/fmri_data/preproc_data//QC_$subj/index.html\n"
 #endif

echo "execution finished: `date`"
