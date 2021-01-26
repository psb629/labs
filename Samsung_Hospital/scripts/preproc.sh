#!/bin/tcsh

set subj = S21
set date = 210112

set root_dir = /Volumes/T7SSD1/samsung_hospital/
set data_dir = /Users/clmn/Desktop/Samsung_Hospital/fmri_data/raw_data/first_scan/${subj}_${date}_MRI
set output_dir = $root_dir/fmri_data/preproc_data/$subj
if ( ! -d $output_dir ) then
	mkdir -p -m 755 $output_dir/preprocessed
endif
set epi = $output_dir/${subj}_fMRI.nii.gz
set t1 = $output_dir/${subj}_T1.nii.gz
#########################################################
## convert dcm files into NIFTI files, written by Sungbeen Park

## T1 data : 366 files
set raw_T1 = $data_dir/${subj}_${date}_T1
dcm2niix_afni -o $output_dir -s y -z y -f "${subj}_T1" $raw_T1
rm $output_dir/*.json
# added the line since S19, because of the unexpected suffix "_real"
mv $output_dir/${subj}_T1*.nii.gz $t1

## fMRI data : 18001 files
set raw_fMRI = $data_dir/${subj}_${date}_FMRI
set TR = 2

set cnt = 0
set set_time = `count -digit 1 1 300`
foreach t_ini ($set_time)
	set set_data = `count -digit 4 $t_ini 18001 300`
	foreach n ($set_data)
		@ cnt = $cnt + 1
		set n_prime = `printf %05d $cnt`
		cp $raw_fMRI/$subj.dcm$n.dcm $output_dir/temp$n_prime.dcm
	end
	set t = `printf %03d $t_ini`
	dcm2niix_afni -o $output_dir -s y -z y -f "${subj}_func$t" $output_dir
	rm $output_dir/*.dcm
end
3dTcat -tr $TR -prefix $output_dir/preprocessed/pb00.$subj.tcat $output_dir/${subj}_func*.nii.gz
rm $output_dir/${subj}_func*.nii.gz
3dAFNItoNIFTI -prefix $epi $output_dir/preprocessed/pb00.$subj.tcat+orig.
rm $output_dir/*.json
# added the line since S19, because of the unexpected suffix "_real"
 #mv $output_dir/${subj}_fMRI*.nii.gz $epi

## DTI data : 3221 files
set raw_DTI = $data_dir/${subj}_${date}_dti

#########################################################
## preprocessing
set fwhm = 4
set thresh_motion = 0.4

cd $output_dir/preprocessed

########
# ANAT #
########
# -------------------------- root 1 --------------------------
3dcopy $t1 $subj.anat+orig.nii.gz
## output : subj.anat+orig
3dWarp -deoblique -prefix $subj.anat.deoblique $subj.anat+orig
## output : subj.anat.deoblique+orig

# -------------------------- branch 1-1 (Kim) --------------------------
3dSkullStrip -input $subj.anat.deoblique+orig -prefix $subj.anat.ss -orig_vol
## output : subj.anat.ss+orig
3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.Unifize -GM
## output : subj.anat.Unifize+orig

# -------------------------- branch 1-2 (Byeon) --------------------------
# os.system('3dresample -orient RAI -prefix %s.anat.rai -inset %s.anat.deoblique+orig' %(subj,subj))
# os.system('3dUnifize -input %s.anat.rai+orig -prefix %s.anat.unifize -GM -clfrac 0.5' %(subj,subj))
# os.system('3dSkullStrip -input %s.anat.unifize+orig -prefix %s.anat.ss -orig_vol' %(subj,subj))

# ================================= tlrc coordinate ==================================
# warp anatomy to standard space
@auto_tlrc -base ~/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.Unifize+orig -no_ss -init_xform AUTO_CENTER
## output :
## subj.anat.Unifize_shift.1D
## pre.subj.anat.Unifize+orig
## subj.anat.Unifize.Xaff12.1D
## subj.anat.Unifize.Xat.1D
## subj.anat.Unifize.maskwarp.Xat.1D
## subj.anat.Unifize+tlrc : 'whereami'

cat_matvec $subj.anat.Unifize+tlrc::WARP_DATA -I > warp.anat.Xat.1D
## output : warp.anat.Xat.1D

# create an anat_final dataset, aligned with stats
#3dcopy $subj.anat.Unifize+tlrc anat_final.$subj
3dcopy $subj.anat.Unifize+orig anat_final.$subj

########
# REST #
########
#================================ tcat =================================
3dTcat -tr 3 -prefix pb00.$subj.rest.tcat $epi
## output : pb00.subj.rest.tcat+orig

3dToutcount -automask -fraction -polort 3 -legendre pb00.$subj.rest.tcat+orig > outcount.$subj.1D
# polort = the polynomial order of the baseline model
## output : outcount.subj.1D

# if ( `1deval -a outcount.$subj.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
#     echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> out.pre_ss_warn.txt
# endif

#================================ despike =================================
## Removes 'spikes' from the 3D+time input dataset and writes a new dataset with the spike values 
## replaced by something more pleasing to the eye.
3dDespike -NEW -nomask -prefix pb00.$subj.rest.despike pb00.$subj.rest.tcat+orig
## output : pb00.subj.rest.despike+orig

# ================================= tshift =================================
## t shift or slice time correction
## time shift data so all slice timing is the same
## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
3dTshift -tzero 0 -quintic -prefix pb01.$subj.rest.tshift pb00.$subj.rest.despike+orig
## tzero -> to interpolate all the slices as though they were all acquired at the beginning of each TR.
## quintic -> 5th order of polynomial
## output : pb01.subj.rest.tshift+orig

# -------------------------- branch 2-2 (epi to anat) --------------------------
# ================================= align ==================================
# - align EPI to anatomical datasets or vice versa
align_epi_anat.py -epi2anat -anat $subj.anat.Unifize+orig -anat_has_skull no \
    -epi pb01.$subj.rest.tshift+orig   -epi_base 3 \
    -epi_strip 3dAutomask                                      \
    -suffix _al_junk                     -check_flip           \
    -volreg off    -tshift off           -ginormous_move       \
    -cost nmi      -align_centers yes
## output :
# subj.anat.Unifize_unflipped+orig
# subj.anat.Unifize_unflipped_ob+orig
# subj.anat.Unifize_unflipped_ob_shft.1D
# subj.anat.Unifize_unflipped_shft_I.1D
# pb01.subj.rest.tshift_ts_ns+orig
# pb01.subj.rest.tshift_ts_ns_wt+orig
# subj.anat.Unifize_unflipped_ob_al_junk_wtal+orig
# subj.anat.Unifize_unflipped_ob_temp_al_junk+orig
# subj.anat.Unifize_al_junk_e2a_only_mat.aff12.1D
# subj.anat.Unifize_flip_al_junk+orig
# subj.anat.Unifize_flip__al_junk_mat.aff12.1D
# __tt_lr_noflipcosts.1D
# __tt_lr_flipcosts.1D
# aea_checkflip_results.txt
# pb01.subj.rest.tshift_al_junk_mat.aff12.1D
# pb01.subj.rest.tshift_al_junk+orig : subj.anat.Unifize+tlrc 와 align

# ================================== register and warp ========================
# register each volume to the base
3dvolreg -verbose -zpad 1 -cubic -base pb01.$subj.rest.tshift_al_junk+orig'[3]' \
    -1Dfile dfile.$subj.rest.1D -prefix rm.epi.volreg.$subj.rest \
    -1Dmatrix_save mat.rest.vr.aff12.1D \
    pb01.$subj.rest.tshift_al_junk+orig
## output :
## mat.rest.vr.aff12.1D
## rm.epi.volreg.subj.rest+orig
## dfile.subj.rest.1D

# create an all-1 dataset to mask the extents of the warp
3dcalc -overwrite -a pb01.$subj.rest.tshift_al_junk+orig -expr 'bool(a)' -prefix rm.$subj.epi.all1
## output : rm.subj.epi.all1+orig

3dcalc -a pb01.$subj.rest.tshift_al_junk+orig -b rm.$subj.epi.all1+orig \
    -expr 'a*b' -prefix pb02.$subj.rest.volreg

# Calculation of motion regressors
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
           -derivative  -collapse_cols euclidean_norm \
           -write motion_${subj}_enorm.1D
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
           -demean -write motion_demean.1D
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
           -derivative -write motion_deriv.1D

#########################################################
#### additional preprocessing after pb02 ####
3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.rest.blur pb02.$subj.rest.volreg+orig

3dTstat -prefix rm.mean_rest pb03.$subj.rest.blur+orig
3dcalc -float -a pb03.$subj.rest.blur+orig -b rm.mean_rest+orig \
		   -c rm.$subj.epi.all1+orig \
		   -expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale

gzip -1v $output_dir/preprocessed/*.BRIK
# ==================================================================
echo "subject $subj completed!"

