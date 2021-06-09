#!/bin/tcsh

set res = 2.683
set fwhm = 4
set thresh_motion = 0.4

# need to revise Start:
set raw_subj = GAB30
set data_root_dir_path = /Users/jerrie/Desktop/clmn/GLM_draft/Data
set output_subj = GAB30

# Output files name
set name_rest = Rest
set name_rest_reverse = Rest_reverse
set name_run1 = RUN1 
set name_run1_reverse = RUN1_reverse
set name_t1 = T1

# (Default)
set name_middle_run = $name_run1

# Output files name list
set output_protocol_name_list = ( \
$name_rest \
$name_rest_reverse \
$name_run1 \
$name_run1_reverse \
$name_t1)

# Must Match with output_protocol_name_list's data without reverse, T1
set output_run_names = ( \
  $name_rest \
  $name_run1 \
)

# need to revise End:

# Directory structure
# data_root_dir_path > fMRI_dir_path > output_dir_path > output_subj_dir_path > output_preproc_dir_path
#	   	     		     > raw_dir_path  > raw_subj_dir_path > raw_subj_head_dir_path

set fMRI_dir_path = $data_root_dir_path/fMRI_data

# raw data path
set raw_dir_path = $fMRI_dir_path/raw_data
set raw_subj_dir_path = $raw_dir_path/$raw_subj
set raw_subj_head_dir_path = $raw_subj_dir_path/HEAD_PI_CNIR_IBS_20210512_093222_936000

# output data path
set output_dir_path = $fMRI_dir_path/output
set output_subj_dir_path = $output_dir_path/$raw_subj
set output_preproc_dir_path = $output_subj_dir_path/preprocessed

mkdir -m 777 $output_dir_path
# mkdir -m 777 $output_subj_dir_path

# fMRI data matching (name, path)
set dir_name_rest = DISTORTION_CORR_64CH_PA_POLARITY_INVERT_TO_AP_0003
set dir_name_rest_reverse = DISTORTION_CORR_64CH_PA_0002

set dir_name_run1 = RUN1_MUITIBAND8_EPI_CMRR_0013
set dir_name_run1_reverse = RUN1_MUITIBAND8_EPI_CMRR_SBREF_0012

set dir_name_T1 = T1_MPRAGE_SAG_1_0ISO_0014

set dir_path_rest = $raw_subj_head_dir_path/$dir_name_rest
set dir_path_rest_reverse = $raw_subj_head_dir_path/$dir_name_rest_reverse

set dir_path_run1 = $raw_subj_head_dir_path/$dir_name_run1
set dir_path_run1_reverse = $raw_subj_head_dir_path/$dir_name_run1_reverse

set dir_path_T1 = $raw_subj_head_dir_path/$dir_name_T1

set dir_path_list = ( $dir_path_rest $dir_path_rest_reverse $dir_path_run1 $dir_path_run1_reverse $dir_path_T1)




# ================================= setp 00 : convert =================================

set i = 1
foreach target_dir ($dir_path_list)
  cd $target_dir
  Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
  -gert_outdir $output_subj_dir_path -gert_quit_on_err
  3dWarp -deoblique -prefix $output_subj_dir_path/$output_protocol_name_list[$i].$output_subj $output_subj_dir_path/temp+orig
  rm $output_subj_dir_path/temp*
  @ i = $i + 1
end


# assign output directory name
if (! -d $output_preproc_dir_path ) then
  mkdir -m 777 $output_preproc_dir_path
else
  echo "output dir($output_preproc_dir_path) already exists!"
endif

# ================================= step01 : tcat & tshift =================================
set i = 1
foreach run_name ($output_run_names)
  cd $output_dir_path
  3dTcat -prefix $output_preproc_dir_path/pb00.$output_subj.r$run_name.tcat $output_subj_dir_path/$run_name.$output_subj+orig'[0..$]'
  @ i = $i + 1
end


cd $output_preproc_dir_path
echo $output_preproc_dir_path
echo $output_subj_dir_path/$output_protocol_name_list[$#output_protocol_name_list].$output_subj+orig
3dcopy $output_subj_dir_path/$output_protocol_name_list[$#output_protocol_name_list].$output_subj+orig $output_subj.anat+orig

touch out.pre_ss_warn.txt
set npol = 4
foreach run_name ($output_run_names)
  3dToutcount -automask -fraction -polort $npol -legendre               \
  pb00.$output_subj.r$run_name.tcat+orig > outcount.$output_subj.r$run_name.1D

  if ( `1deval -a outcount.$output_subj.r$run_name.1D"{0}" -expr "step(a-0.4)"` ) then
    echo "** TR #0 outliers: possible pre-steady state TRs in run ${run_name}" >> out.pre_ss_warn.txt
  endif
end

cat outcount.$output_subj.r*.1D > outcount_rall.$output_subj.1D

# MOLLY ADDED ================================ despike =================================
foreach run_name ($output_run_names)
  3dDespike -NEW -nomask -prefix pb00.$output_subj.r${run_name}.despike pb00.$output_subj.r${run_name}.tcat+orig
end

# ================================= tshift (pb01) =================================
foreach run_name ($output_run_names)
  3dTshift -tzero 0 -quintic -prefix pb01.$output_subj.r${run_name}.tshift \
  pb00.$output_subj.r${run_name}.despike+orig
end

# ================================= step02 : blip =================================

3dTcat -prefix $output_preproc_dir_path/blip_forward $output_subj_dir_path/$output_protocol_name_list[1].$output_subj+orig
3dTcat -prefix $output_preproc_dir_path/blip_reverse $output_subj_dir_path/$output_protocol_name_list[2].$output_subj+orig

# ================================== blip ==================================
3dTstat -median -prefix rm.blip.med.fwd blip_forward+orig
3dTstat -median -prefix rm.blip.med.rev blip_reverse+orig

3dAutomask -apply_prefix rm.blip.med.masked.fwd rm.blip.med.fwd+orig
3dAutomask -apply_prefix rm.blip.med.masked.rev rm.blip.med.rev+orig

3dQwarp -plusminus -pmNAMES Rev For                           \
  -pblur 0.05 0.05 -blur -1 -1                          \
  -noweight -minpatch 9                                 \
  -source rm.blip.med.masked.rev+orig                   \
  -base   rm.blip.med.masked.fwd+orig                   \
  -prefix blip_warp

3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
	-source rm.blip.med.fwd+orig                     \
	-prefix blip_med_for

3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
	-source rm.blip.med.masked.fwd+orig              \
	-prefix blip_med_for_masked

3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig          \
	-source rm.blip.med.masked.rev+orig              \
	-prefix blip_med_rev_masked

 warp EPI time series data
foreach run_name ( $output_run_names )
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig      \
		-source pb01.$output_subj.r$run_name.tshift+orig         \
		-prefix pb01.$output_subj.r$run_name.blip
end

# ================================== step03 : volreg ==================================
3dSkullStrip -input $output_subj.anat+orig -prefix $output_subj.sSanat -orig_vol
3dUnifize -input $output_subj.sSanat+orig -prefix $output_subj.UnisSanat -GM

# - align EPI to anatomical datasets or vice versa
align_epi_anat.py -anat2epi -anat $output_subj.UnisSanat+orig -anat_has_skull no    \
  -epi $output_subj_dir_path/$name_middle_run.$output_subj+orig   -epi_base 0                                \
  -epi_strip 3dAutomask                                                         \
  -suffix _al_junk                     -check_flip                              \
  -volreg off    -tshift off           -ginormous_move                          \
  -cost lpa      -align_centers yes

# ================================== tlrc ==================================
@auto_tlrc -base MNI152_T1_2009c+tlrc.HEAD -input $output_subj.UnisSanat+orig -no_ss -init_xform AUTO_CENTER #-init_xform AUTO_CENTER

cat_matvec $output_subj.UnisSanat+tlrc::WARP_DATA -I > warp.anat.Xat.1D

if ( ! -f $output_subj.UnisSanat+tlrc.HEAD ) then
  echo "** missing +tlrc warp dataset: $output_subj.UnisSanat+tlrc.HEAD"
  exit
endif

# ================================== register and warp (pb02) ========================
foreach run_name ($output_run_names)
  # register each volume to the base
  3dvolreg -verbose -zpad 1 -cubic -base $output_subj_dir_path/$name_middle_run.$output_subj+orig'[0]'         \
    -1Dfile dfile.$output_subj.r$run_name.1D -prefix rm.epi.volreg.$output_subj.r$run_name           \
    -1Dmatrix_save mat.r$run_name.vr.aff12.1D  \
    pb01.$output_subj.r$run_name.blip+orig

  # create an all-1 dataset to mask the extents of the warp
  3dcalc -overwrite -a pb01.$output_subj.r$run_name.blip+orig -expr 1 -prefix rm.$output_subj.epi.all1

  # catenate volreg, epi2anat and tlrc transformations
  cat_matvec -ONELINE $output_subj.UnisSanat+tlrc::WARP_DATA -I $output_subj.UnisSanat_al_junk_mat.aff12.1D -I \
    mat.r$run_name.vr.aff12.1D > mat.$output_subj.r$run_name.warp.aff12.1D

  # apply catenated xform : volreg, epi2anat and tlrc
  3dAllineate -base $output_subj.UnisSanat+tlrc \
    -input pb01.$output_subj.r$run_name.blip+orig \
    -1Dmatrix_apply mat.$output_subj.r$run_name.warp.aff12.1D \
    -mast_dxyz $res   -prefix rm.epi.nomask.$output_subj.r$run_name # $res는 original data의 resolution과 맞춤.

  # warp the all-1 dataset for extents masking
  3dAllineate -base $output_subj.UnisSanat+tlrc \
    -input rm.$output_subj.epi.all1+orig \
    -1Dmatrix_apply mat.$output_subj.r$run_name.warp.aff12.1D \
    -final NN -quiet \
    -mast_dxyz $res  -prefix rm.epi.1.$output_subj.r$run_name

  # make an extents intersection mask of this run
  3dTstat -min -prefix rm.epi.min.$output_subj.r$run_name rm.epi.1.$output_subj.r$run_name+tlrc    # -----NEED CHECK-----
end

# make a single file of registration params
cat dfile.$output_subj.r*.1D > dfile_rall.$output_subj.1D

# ----------------------------------------
3dcopy rm.epi.min.$output_subj.r$name_middle_run+tlrc mask_epi_extents.$output_subj

foreach run_name ($output_run_names)
  3dcalc -a rm.epi.nomask.$output_subj.r$run_name+tlrc -b mask_epi_extents.$output_subj+tlrc \
    -expr 'a*b' -prefix pb02.$output_subj.r$run_name.volreg
end

3dcopy $output_subj.UnisSanat+tlrc anat_final.$output_subj

3dAllineate -source $output_subj.anat+orig \
  -master anat_final.$output_subj+tlrc \
  -final wsinc5 -1Dmatrix_apply warp.anat.Xat.1D \
  -prefix anat_w_skull_warped.$output_subj

foreach run_name ($output_run_names)
  3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$output_subj.r${run_name}.blur \
    pb02.$output_subj.r${run_name}.volreg+tlrc
end

foreach run_name ($output_run_names)
  3dAutomask -dilate 1 -prefix rm.mask_r${run_name} pb03.$output_subj.r${run_name}.blur+tlrc
end

3dmask_tool -inputs rm.mask_r*+tlrc.HEAD -union -prefix full_mask.$output_subj
3dresample -master full_mask.$output_subj+tlrc -input $output_subj.UnisSanat+tlrc -prefix rm.resam.anat
3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$output_subj

foreach run_name ($output_run_names)
  3dTstat -prefix rm.mean_r${run_name} pb03.$output_subj.r${run_name}.blur+tlrc
  3dcalc -float -a pb03.$output_subj.r${run_name}.blur+tlrc -b rm.mean_r${run_name}+tlrc -c mask_epi_extents.$output_subj+tlrc \
    -expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$output_subj.r${run_name}.scale
end

1d_tool.py -infile dfile_rall.$output_subj.1D -set_nruns 1 -demean -write motion_demean.$output_subj.1D
1d_tool.py -infile dfile_rall.$output_subj.1D -set_nruns 1 -derivative -demean -write motion_deriv.$output_subj.1D
1d_tool.py -infile dfile_rall.$output_subj.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$output_subj}

foreach run_name ($output_run_names)
  1d_tool.py -infile dfile.$output_subj.r${run_name}.1D -set_nruns 1 -demean -write motion_demean.$output_subj.r${run_name}.1D
  1d_tool.py -infile dfile.$output_subj.r${run_name}.1D -set_nruns 1 -derivative -demean -write motion_deriv.$output_subj.r${run_name}.1D
  1d_tool.py -infile dfile.$output_subj.r${run_name}.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$output_subj}.r${run_name}
end

1d_tool.py -infile dfile_rall.$output_subj.1D -set_nruns 1      \
  -derivative  -collapse_cols euclidean_norm      \
  -write motion_{$output_subj}.eucl_norm.1D

foreach run_name ($output_run_names)
	1d_tool.py -infile dfile.$output_subj.r${run_name}.1D -set_nruns 1    \
		-derivative  -collapse_cols euclidean_norm     \
		-write motion_{$output_subj}.r${run_name}.eucl_norm.1D
end

# ==================================================================
# ================== delect p00 and p01 ===================
rm ./pb00.*.HEAD ./pb00.*.BRIK
rm ./pb01.*.HEAD ./pb01.*.BRIK
rm ./rm.*

# ================== full mask is converted to .nii.gz file ================== #
set subj_fullmask = $output_subj_dir_path/preprocessed/full_mask.{$output_subj}+tlrc.
set full_mask_dir = $output_dir_path/roi/full
if (! -d $full_mask_dir) then
  mkdir -m 777 -p $full_mask_dir
endif
set pref = $full_mask_dir/full_mask.{$output_subj}.nii.gz
if (! -e $pref) then
  3dAFNItoNIFTI -prefix $pref $subj_fullmask
endif

# ================== gzip ================== #
cd $output_subj_dir_path
gzip -1v *.BRIK

cd ./preprocessed
gzip -1v *.BRIK
# ==================================================================
echo "subject $output_subj completed!"
