#!/bin/zsh

if (( $#argv > 0 )); then
    subj=$argv[1]
else
    subj="invalid"
fi

res=2.683
fwhm=4
thresh_motion=0.4
#=============================================
dir_root="/mnt/sda2/GP/fmri_data"
dir_raw="/mnt/ext4/GP/fmri_data/raw_data"
dir_preproc="$dir_root/preproc_data"
#=============================================
dir_output="$dir_preproc/$subj/day1"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi

T1=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "T1"`
dist_PA=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_INVERT_TO_PA_00??"`
dist_AP=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_AP_00??"`
r00=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "TASK_MUITIBAND8_EPI_CMRR_00??"`
r00_SBREF=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "TASK_MUITIBAND8_EPI_CMRR_SBREF_00??"`
# ================================================================== #
cd $T1
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/MPRAGE.$subj.nii $dir_output/temp+orig
rm $dir_output/temp*

cd $dist_PA
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/dist_PA.$subj.nii $dir_output/temp+orig
rm $dir_output/temp*

cd $dist_AP
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/dist_AP.$subj.nii $dir_output/temp+orig
rm $dir_output/temp*

cd $r00
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/func.$subj.localizer.nii $dir_output/temp+orig
rm $dir_output/temp*

cd $r00_SBREF
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/SBREF.$subj.localizer.nii $dir_output/temp+orig
rm $dir_output/temp*
# ================================================================== #
dir_output="$dir_preproc/$subj/day1/preprocessed"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi

cd $dir_output
# ==================================================================
########
# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
########

# ================================= skull-striping =================================
3dSkullStrip -input "$dir_preproc/$subj/day1/MPRAGE.$subj.nii" -prefix $subj.anat.ss -orig_vol
# ================================= unifize =================================
## this program can be a useful step to take BEFORE 3dSkullStrip, since the latter program can fail if the input volume is strongly shaded -- 3dUnifize will (mostly) remove such shading artifacts.
3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5
# ================================== tlrc ==================================
## warp anatomy to standard space, input dataset must be in the current directory:
@auto_tlrc -base /usr/local/afni/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
## find attribute WARP_DATA in dataset; -I, invert the transformation:
## cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D ## == $subj.anat.unifize.Xat.1D
3dAFNItoNIFTI -prefix anat_final.$subj.nii $subj.anat.unifize+tlrc

# ==================================================================
########
# Func # : Despiking (3dDespike) -> Slice Timing Correction (3dTshift) -> Motion Correct EPI (3dvolreg)
########  -> Alignment (@auto_tlrc) -> Spatial Blurring -> Nuisance Regression -> Scaling

touch out.pre_ss_warn.txt
npol=4
3dToutcount -automask -fraction -polort $npol -legendre $dir_preproc/$subj/day1/func.$subj.localizer.nii > outcount.$subj.localizer.1D
if [ `1deval -a outcount.$subj.localizer.1D"{0}" -expr "step(a-0.4)"` ]; then
	echo "** TR #0 outliers: possible pre-steady state TRs" >> out.$subj.pre_ss_warn.txt
fi
#================================ despike =================================
## truncate spikes in each voxel's time series:
3dDespike -NEW -nomask -prefix pb00.$subj.localizer.despike $dir_preproc/$subj/day1/func.$subj.localizer.nii
# ================================= tshift (pb01) =================================
## slice timing alignment on volumes (default is -time 0)
## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
3dTshift -tzero 0 -quintic -prefix pb01.$subj.localizer.tshift pb00.$subj.localizer.despike+orig
## tzero : to interpolate all the slices as though they were all acquired at the beginning of each TR.
## quintic : 5th order of polynomial
# ================================= blip: B0-distortion correction =================================
## copy external -blip_forward_dset dataset
3dTcat -prefix blip_forward $dir_preproc/$subj/day1/dist_AP.$subj.nii
## copy external -blip_reverse_dset dataset
3dTcat -prefix blip_reverse $dir_preproc/$subj/day1/dist_PA.$subj.nii

## compute blip up/down non-linear distortion correction for EPI

## create median datasets from forward and reverse time series
3dTstat -median -prefix rm.blip.med.fwd blip_forward+orig
3dTstat -median -prefix rm.blip.med.rev blip_reverse+orig

## automask the median datasets
3dAutomask -apply_prefix rm.blip.med.masked.fwd rm.blip.med.fwd+orig
3dAutomask -apply_prefix rm.blip.med.masked.rev rm.blip.med.rev+orig

## compute the midpoint warp between the median datasets
3dQwarp -plusminus -pmNAMES Rev For		\
	-pblur 0.05 0.05 -blur -1 -1		\
	-noweight -minpatch 9				\
	-source rm.blip.med.masked.rev+orig	\
	-base rm.blip.med.masked.fwd+orig	\
	-prefix blip_warp

## warp median datasets (forward and each masked) for QC checks
3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
	-source rm.blip.med.fwd+orig \
	-prefix blip_med_for

3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
	-source rm.blip.med.masked.fwd+orig \
	-prefix blip_med_for_masked

3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig \
	-source rm.blip.med.masked.rev+orig \
	-prefix blip_med_rev_masked

# warp EPI time series data
3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
	-source pb01.$subj.localizer.tshift+orig \
	-prefix pb01.$subj.localizer.blip
# ================================== Align Anatomy with EPI ==================================
## align anatomical datasets to EPI registration base (default: anat2epi):
align_epi_anat.py -anat2epi -anat $subj.anat.unifize+orig -anat_has_skull no \
    -epi $dir_preproc/$subj/day1/SBREF.$subj.localizer.nii -epi_base 3 \
    -epi_strip 3dAutomask \
    -suffix _al_junk -check_flip \
    -volreg off -tshift off -ginormous_move \
    -cost lpa -align_centers yes
## -cost nmi : weired result in the multiband8 protocol
## -cost lpa (local pearson correlation)
# ================================== register and warp (pb02) ========================
## register each volume to the base
3dvolreg -verbose -zpad 1 -cubic -base $dir_preproc/$subj/day1/SBREF.$subj.localizer.nii'[0]' \
	-1Dfile dfile.$subj.localizer.1D -prefix rm.epi.volreg.$subj.localizer           \
	-1Dmatrix_save mat.localizer.vr.aff12.1D  \
	pb01.$subj.localizer.blip+orig

## create an all-1 dataset to mask the extents of the warp
3dcalc -overwrite -a pb01.$subj.localizer.blip+orig -expr 1 -prefix rm.$subj.epi.all1

## catenate volreg, epi2anat and tlrc transformations
cat_matvec -ONELINE $subj.anat.unifize+tlrc::WARP_DATA \
	-I $subj.anat.unifize_al_junk_mat.aff12.1D \
	-I mat.localizer.vr.aff12.1D > mat.$subj.localizer.warp.aff12.1D

## apply catenated xform : volreg, epi2anat and tlrc
3dAllineate -base $subj.anat.unifize+tlrc \
	-input pb01.$subj.localizer.blip+orig \
	-1Dmatrix_apply mat.$subj.localizer.warp.aff12.1D \
	-mast_dxyz $res   -prefix rm.epi.nomask.$subj.localizer # $res는 original data의 resolution과 맞춤e

## warp the all-1 dataset for extents masking
3dAllineate -base $subj.anat.unifize+tlrc \
	-input rm.$subj.epi.all1+orig \
	-1Dmatrix_apply mat.$subj.localizer.warp.aff12.1D \
	-final NN -quiet \
	-mast_dxyz $res  -prefix rm.epi.1.$subj.localizer

## make an extents intersection mask of this run
3dTstat -min -prefix rm.epi.min.$subj.localizer rm.epi.1.$subj.localizer+tlrc    # -----NEED CHECK-----

## create the extents mask: mask_epi_extents+tlrc
## (this is a mask of voxels that have valid data at every TR)
## (only 1 run, so just use 3dcopy to keep naming straight)
3dcopy rm.epi.min.$subj.localizer+tlrc mask_epi_extents.$subj

## and apply the extents mask to the EPI data
## (delete any time series with missing data)
3dcalc -a rm.epi.nomask.$subj.localizer+tlrc -b mask_epi_extents.$subj+tlrc \
	-expr 'a*b' -prefix pb02.$subj.localizer.volreg
# ================================================= blur (pb03) =================================================
## blur each volume of each run
3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.localizer.blur \
	pb02.$subj.localizer.volreg+tlrc
## For each run, blur each volume by a $fwhm mm FWHM (Full Width at Half Max) Gaussian kernel
## $fwhm -> 4 is default, 6 is common

# ================================================= mask =================================================
## create 'full_mask' dataset (union mask)
## create a 'brain' mask from the EPI data (dilate 1 voxel)

3dAutomask -dilate 1 -prefix full_mask.$subj pb03.$subj.localizer.blur+tlrc
## 3dAutomaks  :  Input dataset is EPI 3D+time, or a skull-stripped anatomical. Output dataset is a brain-only mask dataset.
## -dilate nd  = Dilate the mask outwards 'nd' times.

## ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
##      (resampled from tlrc anat). resample은 resolution을 맞춰 sampling을 다시 하는 것. resolution을 낮추면 down sampling하는 것.
3dresample -master full_mask.$subj+tlrc -input $subj.anat.unifize+tlrc -prefix rm.resam.anat
## convert to binary anat mask; fill gaps and holes
3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj

# ================================= scale (pb04) ==================================
## scale each voxel time series to have a mean of 100 (be sure no negatives creep in)
## (subject to a range of [0,200])
3dTstat -prefix rm.mean_localizer pb03.$subj.localizer.blur+tlrc
3dcalc -float -a pb03.$subj.localizer.blur+tlrc -b rm.mean_localizer+tlrc -c mask_epi_extents.$subj+tlrc \
	-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.localizer.scale
# ================================ motion regressors =================================
## -demean : demean each run (new mean of each run = 0.0)
## -derivative : take the temporal derivative of each vector (done as first backward difference)
## compute de-meaned motion parameters (for use in regression)
1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1 -demean -write motion_demean.$subj.localizer.1D
## compute motion parameter derivatives (just to have)
1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.localizer.1D
## create censor file motion_$subj_censor.1D, for censoring motion, -censor_prev_TR : for each censored TR, also censor previous
1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_${subj}

## compute motion magnitude time series: the Euclidean norm
## (sqrt(sum squares)) of the motion parameter derivatives
1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1 \
	-derivative  -collapse_cols euclidean_norm \
	-write motion_$subj.eucl_norm.1D

1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1 \
	-derivative  -collapse_cols euclidean_norm     \
	-write motion_$subj.localizer.eucl_norm.1D
