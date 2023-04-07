#!/bin/tcsh
set subj = $argv[1]
set work_dir = /Users/sskim/Documents/Research/AFNI/SMC

cd $work_dir/$subj
mkdir preproc
set output_dir = $work_dir/$subj/preproc

## combinine dicom
#Dimon -infile_pat '*.dcm' -gert_create_dataset -gert_to3d_prefix temp \
#-gert_outdir $output_dir -gert_quit_on_err

# tcat
#3dTcat -tr 3 -prefix $output_dir/pb00.$subj.rest.tcat *fMRI*nii.gz
#3dTcat -tr 3 -prefix $output_dir/pb00.$subj.rest.tcat test*nii
cd $output_dir
3dcopy $work_dir/$subj/*T1*nii.gz $output_dir/$subj.anat+orig

3dToutcount -automask -fraction -polort 3 -legendre \

#================================ despike =================================
3dDespike -NEW -nomask -prefix pb00.$subj.rest.despike pb00.$subj.rest.tcat+orig


# ================================= tshift =================================
3dTshift -tzero 0 -quintic -prefix pb01.$subj.rest.tshift pb00.$subj.rest.despike+orig

#3dWarp -deoblique -prefix pb00.$subj.rest.deoblique pb00.$subj.rest.tshift+orig
#pb00.$subj.rest.deoblique+orig > outcount.$subj.rest.1D

set fwhm = 4
set thresh_motion = 0.4


# ================================= align ==================================
# for e2a: compute anat alignment transformation to EPI registration base
# (new anat will be intermediate, stripped, epi_$subjID.anat_ns+orig)

# 3dSkullStrip -input VOL -prefix VOL_PREFIX
3dWarp -deoblique -prefix $subj.anat.deoblique $subj.anat+orig
3dSkullStrip -input $subj.anat.deoblique+orig -prefix $subj.sSanat -orig_vol
3dUnifize -input $subj.sSanat+orig -prefix $subj.UnisSanat -GM

# - align EPI to anatomical datasets or vice versa
align_epi_anat.py -anat2epi -anat $subj.UnisSanat+orig -anat_has_skull no    \
-epi $output_dir/pb01.$subj.rest.tshift+orig   -epi_base 3                             \
-epi_strip 3dAutomask                                                         \
-suffix _al_junk                     -check_flip                              \
-volreg off    -tshift off           -ginormous_move                          \
-cost nmi      
#-align_centers yes

# ================================= tlrc ==================================

@auto_tlrc -base ~/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.UnisSanat+orig \
-no_ss -init_xform AUTO_CENTER

cat_matvec $subj.UnisSanat+tlrc::WARP_DATA -I > warp.anat.Xat.1D


# ================================== register and warp ========================
# register each volume to the base
3dvolreg -verbose -zpad 1 -cubic -base pb01.$subj.rest.tshift+orig'[3]'         \
-1Dfile dfile.$subj.rest.1D -prefix rm.epi.volreg.$subj.rest           \
-1Dmatrix_save mat.rest.vr.aff12.1D  \
pb01.$subj.rest.tshift+orig

# create an all-1 dataset to mask the extents of the warp
3dcalc -overwrite -a pb01.$subj.rest.tshift+orig -expr 1 -prefix rm.$subj.epi.all1

# catenate volreg, epi2anat and tlrc transformations
 cat_matvec -ONELINE                            \
 $subj.UnisSanat_al_junk_mat.aff12.1D -I        \
 mat.rest.vr.aff12.1D > mat.$subj.rest.warp.aff12.1D

# apply catenated xform : volreg, epi2anat and tlrc
 3dAllineate -base $subj.UnisSanat+orig \
 -input pb01.$subj.rest.tshift+orig \
 -1Dmatrix_apply mat.$subj.rest.warp.aff12.1D \
 -master pb01.$subj.rest.tshift+orig  -prefix rm.epi.nomask.$subj.rest

# warp the all-1 dataset for extents masking
 3dAllineate -base $subj.UnisSanat+orig \
 -input rm.$subj.epi.all1+orig \
 -1Dmatrix_apply mat.$subj.rest.warp.aff12.1D \
 -final NN -quiet \
 -master pb01.$subj.rest.tshift+orig -prefix rm.epi.1.$subj.rest

# make an extents intersection mask of this run
3dTstat -min -prefix rm.epi.min.$subj.rest rm.epi.1.$subj.rest+orig    # -----NEED CHECK-----
3dcopy rm.epi.min.$subj.rest+orig mask_epi_extents.$subj
3dcalc -a rm.epi.nomask.$subj.rest+orig -b mask_epi_extents.$subj+orig    \
-expr 'a*b' -prefix pb02.$subj.rest.volreg


 # Calculation of motion regressors
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1                      \
           -derivative  -collapse_cols euclidean_norm                     \
           -write motion_${subj}_enorm.1D
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1                       \
           -demean -write motion_demean.1D
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1                       \
           -derivative -write motion_derev.1D

# create an anat_final dataset, aligned with stats
3dcopy $subj.UnisSanat+tlrc anat_final.$subj
3dcopy $subj.UnisSanat+orig anat_final.$subj


# warp anat follower datasets (affine)
# warp data with a skull
3dAllineate -source $subj.anat+orig \
-master anat_final.$subj+tlrc \
-final wsinc5 \
-1Dmatrix_apply warp.anat.Xat.1D \
-prefix anat_w_skull_warped.$subj

# ================================================= blur =================================================
3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.rest.blur pb02.$subj.rest.volreg+orig


# ================================================= mask =================================================
 3dAutomask -dilate 1 -prefix rm.mask_rest pb03.$subj.rest.blur+orig
 3dmask_tool -inputs rm.mask_rest+orig.HEAD -union -prefix full_mask.$subj
 # ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
#      (resampled from tlrc anat). resample은 resolution을 맞춰 sampling을 다시 하는 것. resolution을 낮추면 down sampling하는 것.
 3dresample -master full_mask.$subj+orig -input $subj.UnisSanat+orig -prefix rm.resam.anat
 # convert to binary anat mask; fill gaps and holes
 3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+orig -prefix mask_anat.$subj

 # ================================= scale ==================================
3dTstat -prefix rm.mean_rest pb03.$subj.rest.blur+orig
3dcalc -float -a pb03.$subj.rest.blur+orig -b rm.mean_rest+orig -c mask_epi_extents.$subj+orig \
-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale
