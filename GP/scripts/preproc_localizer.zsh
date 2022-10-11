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
dir_root="/mnt/ext6/GP/fmri_data"
dir_raw="$dir_root/raw_data"
dir_preproc="$dir_root/preproc_data"
#=============================================
dir_output="$dir_preproc/$subj/day1"
if [ ! -d $dir_output ]; then
	mkdir -p -mm 755 $dir_output
fi

dist_PA=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_INVERT_TO_PA_00??"`
dist_AP=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_AP_00??"`
r00=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "TASK_MUITIBAND8_EPI_CMRR_00??"`
r00_SBREF=`find "$dir_raw/$subj/day1" -maxdepth 1 -mindepth 1 -type d -name "TASK_MUITIBAND8_EPI_CMRR_SBREF_00??"`
# ================================================================== #
cd $dist_PA
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/dist_PA.$subj $dir_output/temp+orig
rm $dir_output/temp*

cd $dist_AP
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/dist_AP.$subj $dir_output/temp+orig
rm $dir_output/temp*

cd $r00
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/func.$subj.localizer $dir_output/temp+orig
rm $dir_output/temp*

cd $r00_SBREF
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/SBREF.$subj.localizer $dir_output/temp+orig
rm $dir_output/temp*
# ================================================================== #

cd $dir_output/preprocessed

touch out.pre_ss_warn.txt
npol=4
3dToutcount -automask -fraction -polort $npol -legendre $dir_output/func.$subj.localizer+orig > outcount.$subj.localizer.1D
if [ `1deval -a outcount.$subj.localizer.1D"{0}" -expr "step(a-0.4)"` ]; then
	echo "** TR #0 outliers: possible pre-steady state TRs" >> out.$subj.pre_ss_warn.txt
fi
#================================ despike =================================
## truncate spikes in each voxel's time series:
3dDespike -NEW -nomask -prefix pb00.$subj.localizer.despike $dir_output/func.$subj.localizer+orig
# ================================= tshift (pb01) =================================
## slice timing alignment on volumes (default is -time 0)
## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
3dTshift -tzero 0 -quintic -prefix pb01.$subj.localizer.tshift pb00.$subj.localizer.despike+orig
## tzero : to interpolate all the slices as though they were all acquired at the beginning of each TR.
## quintic : 5th order of polynomial
# ================================= blip: B0-distortion correction =================================
## copy external -blip_forward_dset dataset
3dTcat -prefix blip_forward $dir_output/dist_AP.$subj+orig
## copy external -blip_reverse_dset dataset
3dTcat -prefix blip_reverse $dir_output/dist_PA.$subj+orig

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
    -epi $dir_output/SBREF.$subj.localizer+orig -epi_base 3 \
    -epi_strip 3dAutomask \
    -suffix _al_junk -check_flip \
    -volreg off -tshift off -ginormous_move \
    -cost lpa -align_centers yes
## -cost nmi : weired result in the multiband8 protocol
## -cost lpa (local pearson correlation)
# ================================== register and warp (pb02) ========================
## register each volume to the base
3dvolreg -verbose -zpad 1 -cubic -base $dir_output/SBREF.$subj.localizer+orig'[0]' \
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

 #
 #3dDeconvolve -input /Volumes/clmnlab/GA/fmri_data/preproc_data/GA01/pb04.GA01.r00.scale+tlrc -mask /Volumes/T7SSD1/GA/fMRI_data/roi/full/full_mask.GA01.nii.gz -censor /Volumes/T7SSD1/GA/fMRI_data/preproc_data/01/motion_censor.GA01.r00.1D -polort A -float -local_times -num_stimts 8 -num_glt 1 -stim_times_AM1 1 /Volumes/T7SSD1/GA/behav_data/regressors/move-stop/01_Move.txt dmBLOCK -stim_label 1 Move -stim_times_AM1 2 /Volumes/T7SSD1/GA/behav_data/regressors/move-stop/01_Stop.txt dmBLOCK -stim_label 2 Stop -stim_file 3 '/Volumes/T7SSD1/GA/fMRI_data/preproc_data/01/motion_demean.GA01.r00.1D[0]' -stim_base 3 -stim_label 3 roll -stim_file 4 '/Volumes/T7SSD1/GA/fMRI_data/preproc_data/01/motion_demean.GA01.r00.1D[1]' -stim_base 4 -stim_label 4 pitch -stim_file 5 '/Volumes/T7SSD1/GA/fMRI_data/preproc_data/01/motion_demean.GA01.r00.1D[2]' -stim_base 5 -stim_label 5 yaw -stim_file 6 '/Volumes/T7SSD1/GA/fMRI_data/preproc_data/01/motion_demean.GA01.r00.1D[3]' -stim_base 6 -stim_label 6 dS -stim_file 7 '/Volumes/T7SSD1/GA/fMRI_data/preproc_data/01/motion_demean.GA01.r00.1D[4]' -stim_base 7 -stim_label 7 dL -stim_file 8 '/Volumes/T7SSD1/GA/fMRI_data/preproc_data/01/motion_demean.GA01.r00.1D[5]' -stim_base 8 -stim_label 8 dP -gltsym 'SYM: Move -Stop' -glt_label 1 Move-Stop -jobs 4 -fout -tout -x1D ./X.statMove.xmat.1D -xjpeg ./X.statMove.jpg -x1D_uncensored ./X.statMove.nocensor.xmat.1D -bucket ./statMove.01
 #
