#!/bin/tcsh -xef

echo "auto-generated by afni_proc.py, Tue Mar 29 14:37:29 2022"
echo "(version 7.17, July 16, 2021)"
echo "execution started: `date`"

# to execute via tcsh: 
#   tcsh -xef /mnt/sda2/GA/fmri_data/preproc_data/02/proc_GA02.tcsh |& tee /mnt/sda2/GA/fmri_data/preproc_data/02/output.proc_GA02.tcsh
# to execute via bash: 
#   tcsh -xef /mnt/sda2/GA/fmri_data/preproc_data/02/proc_GA02.tcsh 2>&1 | tee /mnt/sda2/GA/fmri_data/preproc_data/02/output.proc_GA02.tcsh

# =========================== auto block: setup ============================
# script setup

# take note of the AFNI version
afni -ver

# check that the current AFNI version is recent enough
afni_history -check_date 27 Jun 2019
if ( $status ) then
    echo "** this script requires newer AFNI binaries (than 27 Jun 2019)"
    echo "   (consider: @update.afni.binaries -defaults)"
    exit
endif

# the user may specify a single subject to run with
if ( $#argv > 0 ) then
    set subj = $argv[1]
endif

set gg = `printf '%s' $subj | cut -c 1-2`
set nn = `printf '%s' $subj | cut -c 3-4`

# assign output directory name
set output_dir = /mnt/sda2/GA/fmri_data/preproc_data/$nn/$gg
set output_dir = /mnt/ext5/NAS05/GA/fmri_data/preproc_data/$nn/$gg

# verify that the results directory does not yet exist
if ( -d $output_dir ) then
    echo output dir "$subj.results" already exists
    exit
endif

# set list of runs
set runs = (`count -digits 2 1 6`)

# create results directory
mkdir -p $output_dir

# copy anatomy to results dir
3dcopy /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.MPRAGE.nii \
    $output_dir/$subj.MPRAGE

# copy external -blip_forward_dset dataset
3dTcat -prefix $output_dir/blip_forward \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.dist_AP.nii
# copy external -blip_reverse_dset dataset
3dTcat -prefix $output_dir/blip_reverse \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.dist_PA.nii

# ============================ auto block: tcat ============================
# apply 3dTcat to copy input dsets to results dir,
# while removing the first 0 TRs
3dTcat -prefix $output_dir/pb00.$subj.r01.tcat \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.func.r01.nii'[0..$]'
3dTcat -prefix $output_dir/pb00.$subj.r02.tcat \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.func.r02.nii'[0..$]'
3dTcat -prefix $output_dir/pb00.$subj.r03.tcat \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.func.r03.nii'[0..$]'
3dTcat -prefix $output_dir/pb00.$subj.r04.tcat \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.func.r04.nii'[0..$]'
3dTcat -prefix $output_dir/pb00.$subj.r05.tcat \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.func.r05.nii'[0..$]'
3dTcat -prefix $output_dir/pb00.$subj.r06.tcat \
    /mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.func.r06.nii'[0..$]'

# and make note of repetitions (TRs) per run
set tr_counts = ( 1096 1096 1096 1096 1096 1096 )

# -------------------------------------------------------
# enter the results directory (can begin processing data)
cd $output_dir


# ========================= uniformity correction ==========================
# perform 'unifize' uniformity correction on anatomical dataset
3dUnifize -prefix $subj.MPRAGE_unif -GM $subj.MPRAGE+orig

# ========================== auto block: outcount ==========================
# data check: compute outlier fraction for each volume
touch out.pre_ss_warn.txt
foreach run ( $runs )
    3dToutcount -automask -fraction -polort 4 -legendre                     \
                pb00.$subj.r$run.tcat+orig > outcount.r$run.1D

    # censor outlier TRs per run, ignoring the first 0 TRs
    # - censor when more than 0.05 of automask voxels are outliers
    # - step() defines which TRs to remove via censoring
    1deval -a outcount.r$run.1D -expr "1-step(a-0.05)" > rm.out.cen.r$run.1D

    # outliers at TR 0 might suggest pre-steady state TRs
    if ( `1deval -a outcount.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
        echo "** TR #0 outliers: possible pre-steady state TRs in run $run" \
            >> out.pre_ss_warn.txt
    endif
end

# catenate outlier counts into a single time series
cat outcount.r*.1D > outcount_rall.1D

# catenate outlier censor files into a single time series
cat rm.out.cen.r*.1D > outcount_${subj}_censor.1D

# get run number and TR index for minimum outlier volume
set minindex = `3dTstat -argmin -prefix - outcount_rall.1D\'`
set ovals = ( `1d_tool.py -set_run_lengths $tr_counts                       \
                          -index_to_run_tr $minindex` )
# save run and TR indices for extraction of vr_base_min_outlier
set minoutrun = $ovals[1]
set minouttr  = $ovals[2]
echo "min outlier: run $minoutrun, TR $minouttr" | tee out.min_outlier.txt

# ================================ despike =================================
# apply 3dDespike to each run
foreach run ( $runs )
    3dDespike -NEW -nomask -prefix pb01.$subj.r$run.despike \
        pb00.$subj.r$run.tcat+orig
end

# ================================= tshift =================================
# time shift data so all slice timing is the same 
foreach run ( $runs )
    3dTshift -tzero 0 -quintic -prefix pb02.$subj.r$run.tshift \
             -tpattern alt+z2                                  \
             pb01.$subj.r$run.despike+orig
end

# ================================== blip ==================================
# compute blip up/down non-linear distortion correction for EPI

# create median datasets from forward and reverse time series
3dTstat -median -prefix rm.blip.med.fwd blip_forward+orig
3dTstat -median -prefix rm.blip.med.rev blip_reverse+orig

# automask the median datasets 
3dAutomask -apply_prefix rm.blip.med.masked.fwd rm.blip.med.fwd+orig
3dAutomask -apply_prefix rm.blip.med.masked.rev rm.blip.med.rev+orig

# compute the midpoint warp between the median datasets
3dQwarp -plusminus -pmNAMES Rev For                           \
        -pblur 0.05 0.05 -blur -1 -1                          \
        -noweight -minpatch 9                                 \
        -source rm.blip.med.masked.rev+orig                   \
        -base   rm.blip.med.masked.fwd+orig                   \
        -prefix blip_warp

# warp median datasets (forward and each masked) for QC checks
3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
             -source rm.blip.med.fwd+orig                     \
             -prefix blip_med_for

3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
             -source rm.blip.med.masked.fwd+orig              \
             -prefix blip_med_for_masked

3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig          \
             -source rm.blip.med.masked.rev+orig              \
             -prefix blip_med_rev_masked

# warp EPI time series data
foreach run ( $runs )
    3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig      \
                 -source pb02.$subj.r$run.tshift+orig         \
                 -prefix pb03.$subj.r$run.blip
end

# --------------------------------
# extract volreg registration base
3dbucket -prefix vr_base_min_outlier                          \
    pb03.$subj.r$minoutrun.blip+orig"[$minouttr]"

# ================================= align ==================================
# for e2a: compute anat alignment transformation to EPI registration base
# (new anat will be intermediate, stripped, $subj.MPRAGE_unif_ns+orig)
align_epi_anat.py -anat2epi -anat $subj.MPRAGE_unif+orig \
       -save_skullstrip -suffix _al_junk                \
       -epi vr_base_min_outlier+orig -epi_base 0        \
       -epi_strip 3dAutomask                            \
       -cost lpc+ZZ -giant_move -check_flip             \
       -volreg off -tshift off

# ================================== tlrc ==================================
# warp anatomy to standard space
@auto_tlrc -base MNI152_T1_2009c+tlrc -input $subj.MPRAGE_unif_ns+orig -no_ss \
             -init_xform AUTO_CENTER

# store forward transformation matrix in a text file
cat_matvec $subj.MPRAGE_unif_ns+tlrc::WARP_DATA -I > warp.anat.Xat.1D

# ================================= volreg =================================
# align each dset to base volume, blip warp, to anat, warp to tlrc space
# (final warp input is same as blip input)

# verify that we have a +tlrc warp dataset
if ( ! -f $subj.MPRAGE_unif_ns+tlrc.HEAD ) then
    echo "** missing +tlrc warp dataset: $subj.MPRAGE_unif_ns+tlrc.HEAD" 
    exit
endif

# register and warp
foreach run ( $runs )
    # register each volume to the base image
    3dvolreg -verbose -zpad 1 -base vr_base_min_outlier+orig              \
             -1Dfile dfile.r$run.1D -prefix rm.epi.volreg.r$run           \
             -cubic                                                       \
             -1Dmatrix_save mat.r$run.vr.aff12.1D                         \
             pb03.$subj.r$run.blip+orig

    # create an all-1 dataset to mask the extents of the warp
    3dcalc -overwrite -a pb03.$subj.r$run.blip+orig -expr 1               \
           -prefix rm.epi.all1

    # catenate blip/volreg/epi2anat/tlrc xforms
    cat_matvec -ONELINE                                                   \
               $subj.MPRAGE_unif_ns+tlrc::WARP_DATA -I                     \
               $subj.MPRAGE_unif_al_junk_mat.aff12.1D -I                   \
               mat.r$run.vr.aff12.1D > mat.r$run.warp.aff12.1D

    # apply catenated xform: blip/volreg/epi2anat/tlrc
    3dNwarpApply -master $subj.MPRAGE_unif_ns+tlrc -dxyz 2.5               \
                 -source pb02.$subj.r$run.tshift+orig                     \
                 -nwarp "mat.r$run.warp.aff12.1D blip_warp_For_WARP+orig" \
                 -prefix rm.epi.nomask.r$run

    # warp the all-1 dataset for extents masking 
    3dAllineate -base $subj.MPRAGE_unif_ns+tlrc                            \
                -input rm.epi.all1+orig                                   \
                -1Dmatrix_apply mat.r$run.warp.aff12.1D                   \
                -mast_dxyz 2.5 -final NN -quiet                           \
                -prefix rm.epi.1.r$run

    # make an extents intersection mask of this run
    3dTstat -min -prefix rm.epi.min.r$run rm.epi.1.r$run+tlrc
end

# make a single file of registration params
cat dfile.r*.1D > dfile_rall.1D

# ----------------------------------------
# create the extents mask: mask_epi_extents+tlrc
# (this is a mask of voxels that have valid data at every TR)
3dMean -datum short -prefix rm.epi.mean rm.epi.min.r*.HEAD 
3dcalc -a rm.epi.mean+tlrc -expr 'step(a-0.999)' -prefix mask_epi_extents

# and apply the extents mask to the EPI data 
# (delete any time series with missing data)
foreach run ( $runs )
    3dcalc -a rm.epi.nomask.r$run+tlrc -b mask_epi_extents+tlrc           \
           -expr 'a*b' -prefix pb04.$subj.r$run.volreg
end

# warp the volreg base EPI dataset to make a final version
cat_matvec -ONELINE                                                       \
           $subj.MPRAGE_unif_ns+tlrc::WARP_DATA -I                         \
           $subj.MPRAGE_unif_al_junk_mat.aff12.1D -I  > mat.basewarp.aff12.1D

3dAllineate -base $subj.MPRAGE_unif_ns+tlrc                                \
            -input vr_base_min_outlier+orig                               \
            -1Dmatrix_apply mat.basewarp.aff12.1D                         \
            -mast_dxyz 2.5                                                \
            -prefix final_epi_vr_base_min_outlier

# create an anat_final dataset, aligned with stats
3dcopy $subj.MPRAGE_unif_ns+tlrc anat_final.$subj

# record final registration costs
3dAllineate -base final_epi_vr_base_min_outlier+tlrc -allcostX            \
            -input anat_final.$subj+tlrc |& tee out.allcostX.txt

# -----------------------------------------
# warp anat follower datasets (affine)
3dAllineate -source $subj.MPRAGE_unif+orig                                 \
            -master anat_final.$subj+tlrc                                 \
            -final wsinc5 -1Dmatrix_apply warp.anat.Xat.1D                \
            -prefix anat_w_skull_warped

# ================================== blur ==================================
# blur each volume of each run
foreach run ( $runs )
    3dmerge -1blur_fwhm 4.0 -doall -prefix pb05.$subj.r$run.blur \
            pb04.$subj.r$run.volreg+tlrc
end

# ================================== mask ==================================
# create 'full_mask' dataset (union mask)
foreach run ( $runs )
    3dAutomask -prefix rm.mask_r$run pb05.$subj.r$run.blur+tlrc
end

# create union of inputs, output type is byte
3dmask_tool -inputs rm.mask_r*+tlrc.HEAD -union -prefix full_mask.$subj

# ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
#      (resampled from tlrc anat)
3dresample -master full_mask.$subj+tlrc -input $subj.MPRAGE_unif_ns+tlrc \
           -prefix rm.resam.anat

# convert to binary anat mask; fill gaps and holes
3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc    \
            -prefix mask_anat.$subj

# compute tighter EPI mask by intersecting with anat mask
3dmask_tool -input full_mask.$subj+tlrc mask_anat.$subj+tlrc            \
            -inter -prefix mask_epi_anat.$subj

# compute overlaps between anat and EPI masks
3dABoverlap -no_automask full_mask.$subj+tlrc mask_anat.$subj+tlrc      \
            |& tee out.mask_ae_overlap.txt

# note Dice coefficient of masks, as well
3ddot -dodice full_mask.$subj+tlrc mask_anat.$subj+tlrc                 \
      |& tee out.mask_ae_dice.txt

# ---- create group anatomy mask, mask_group+tlrc ----
#      (resampled from tlrc base anat, MNI152_T1_2009c+tlrc)
3dresample -master full_mask.$subj+tlrc -prefix ./rm.resam.group        \
           -input /usr/local/afni/abin/MNI152_T1_2009c+tlrc

# convert to binary group mask; fill gaps and holes
3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.group+tlrc   \
            -prefix mask_group

# note Dice coefficient of anat and template masks
3ddot -dodice mask_anat.$subj+tlrc mask_group+tlrc                      \
      |& tee out.mask_at_dice.txt

# ================================= scale ==================================
# scale each voxel time series to have a mean of 100
# (be sure no negatives creep in)
# (subject to a range of [0,200])
foreach run ( $runs )
    3dTstat -prefix rm.mean_r$run pb05.$subj.r$run.blur+tlrc
    3dcalc -a pb05.$subj.r$run.blur+tlrc -b rm.mean_r$run+tlrc \
           -c mask_epi_extents+tlrc                            \
           -expr 'c * min(200, a/b*100)*step(a)*step(b)'       \
           -prefix pb06.$subj.r$run.scale
end

# ================================ regress =================================

# compute de-meaned motion parameters (for use in regression)
1d_tool.py -infile dfile_rall.1D -set_nruns 6                           \
           -demean -write motion_demean.1D

# compute motion parameter derivatives (for use in regression)
1d_tool.py -infile dfile_rall.1D -set_nruns 6                           \
           -derivative -demean -write motion_deriv.1D

# convert motion parameters for per-run regression
1d_tool.py -infile motion_demean.1D -set_nruns 6                        \
           -split_into_pad_runs mot_demean

1d_tool.py -infile motion_deriv.1D -set_nruns 6                         \
           -split_into_pad_runs mot_deriv

# create censor file motion_${subj}_censor.1D, for censoring motion 
1d_tool.py -infile dfile_rall.1D -set_nruns 6                           \
    -show_censor_count -censor_prev_TR                                  \
    -censor_motion 0.4 motion_${subj}

# combine multiple censor files
1deval -a motion_${subj}_censor.1D -b outcount_${subj}_censor.1D        \
       -expr "a*b" > censor_${subj}_combined_2.1D

# create bandpass regressors (instead of using 3dBandpass, say)
# (make separate regressors per run, with all in one file)
foreach index ( `count -digits 1 1 $#runs` )
    set nt = $tr_counts[$index]
    set run = $runs[$index]
    1dBport -nodata $nt 0.46 -band 0.01 0.1 -invert -nozero >! rm.bpass.1D
    1d_tool.py -infile rm.bpass.1D -pad_into_many_runs $run $#runs      \
               -set_run_lengths $tr_counts                              \
               -write bpass.r$run.1D
end
1dcat bpass.r*1D > bandpass_rall.1D

# note TRs that were not censored
set ktrs = `1d_tool.py -infile censor_${subj}_combined_2.1D             \
                       -show_trs_uncensored encoded`

# ------------------------------
# run the regression analysis
3dDeconvolve -input pb06.$subj.r*.scale+tlrc.HEAD                       \
    -censor censor_${subj}_combined_2.1D                                \
    -ortvec bandpass_rall.1D bandpass                                   \
    -ortvec mot_demean.r01.1D mot_demean_r01                            \
    -ortvec mot_demean.r02.1D mot_demean_r02                            \
    -ortvec mot_demean.r03.1D mot_demean_r03                            \
    -ortvec mot_demean.r04.1D mot_demean_r04                            \
    -ortvec mot_demean.r05.1D mot_demean_r05                            \
    -ortvec mot_demean.r06.1D mot_demean_r06                            \
    -ortvec mot_deriv.r01.1D mot_deriv_r01                              \
    -ortvec mot_deriv.r02.1D mot_deriv_r02                              \
    -ortvec mot_deriv.r03.1D mot_deriv_r03                              \
    -ortvec mot_deriv.r04.1D mot_deriv_r04                              \
    -ortvec mot_deriv.r05.1D mot_deriv_r05                              \
    -ortvec mot_deriv.r06.1D mot_deriv_r06                              \
    -polort 4                                                           \
    -num_stimts 0                                                       \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -fitts fitts.$subj                                                  \
    -errts errts.${subj}                                                \
    -x1D_stop                                                           \
    -bucket stats.$subj

# -- use 3dTproject to project out regression matrix --
#    (make errts like 3dDeconvolve, but more quickly)
3dTproject -polort 0 -input pb06.$subj.r*.scale+tlrc.HEAD               \
           -censor censor_${subj}_combined_2.1D -cenmode ZERO           \
           -ort X.nocensor.xmat.1D -prefix errts.${subj}.tproject


# ========================== auto block: finalize ==========================

# remove temporary files
rm rm.*

echo "execution finished: `date`"

# ==========================================================================
# script generated by the command:
#
# afni_proc.py -subj_id GA02 -script                                         \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/proc_GA02.tcsh                  \
#     -blip_forward_dset                                                     \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.dist_AP.nii                \
#     -blip_reverse_dset                                                     \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.dist_PA.nii -out_dir       \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/preprocessed -dsets             \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.func.r01.nii               \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.func.r02.nii               \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.func.r03.nii               \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.func.r04.nii               \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.func.r05.nii               \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.func.r06.nii -blocks       \
#     despike tshift align tlrc volreg blur mask scale regress -copy_anat    \
#     /mnt/sda2/GA/fmri_data/preproc_data/02/GA02.MPRAGE.nii -anat_has_skull \
#     yes -anat_uniform_method unifize -anat_unif_GM yes                     \
#     -tcat_remove_first_trs 0 -tshift_opts_ts -tpattern alt+z2 -tlrc_base   \
#     MNI152_T1_2009c+tlrc -tlrc_opts_at -init_xform AUTO_CENTER             \
#     -align_opts_aea -cost lpc+ZZ -giant_move -check_flip -volreg_align_e2a \
#     -volreg_align_to MIN_OUTLIER -volreg_tlrc_warp -blur_size 4.0          \
#     -regress_censor_motion 0.4 -regress_censor_outliers 0.05               \
#     -regress_bandpass 0.01 0.1 -regress_motion_per_run                     \
#     -regress_apply_mot_types demean deriv -html_review_style pythonic
