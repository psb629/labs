#!/bin/zsh

thresh_motion=0.4
fwhm=4 # Full width at half maximum

## ======================================================== ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
		-s | --subject)
			subj="$2"
		;;
		-h | --help)
			echo "-s, --subject:\n\t-s S06"
		;;
	esac
	shift ##takes one argument
done
## ======================================================== ##
dir_root="/mnt/ext5/SMC/fmri_data"

dir_raw=`find $dir_root/raw_data/pre -maxdepth 1 -type d -name "${subj}_*"`
dir_work="$dir_root/preproc_data/To_search.target/$subj"
if [ ! -d $dir_work ]; then
	mkdir -p -m 755 $dir_work
fi
## ======================== Preprocessing ======================== ##
cd $dir_work

########
# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
########
t1="$dir_raw/$subj.T1.nii"

3dcalc -a $t1 -expr "a*0.01" -prefix $subj.anat+orig
3dWarp -deoblique -prefix $subj.anat.deoblique $subj.anat+orig > deoblique.$subj.aff.2D

# ================ change the orientation of a dataset ================ #
3dresample -orient LPI -prefix $subj.anat.lpi -input $subj.anat+orig

# ================================= skull-striping ================================= #
3dSkullStrip -input $subj.anat.lpi+orig -prefix $subj.anat.ss -orig_vol
# ================================= unifize ================================= #
3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5

# ================================= tlrc coordinate ================================== #
@auto_tlrc -base MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D

########
# Func # : Despiking (3dDespike) -> Slice Timing Correction (3dTshift) -> Motion Correct EPI (3dvolreg)
########  -> Alignment (@auto_tlrc) -> Spatial Blurring -> Nuisance Regression -> Scaling
epi="$dir_raw/$subj.func.nii"
# ================================ tcat =================================
## copy input datasets and remove unwanted initial TRs:
3dTcat -tr 2 -prefix pb00.$subj.rest.tcat $epi

# ================================= outcount =================================
3dToutcount -automask -fraction -polort 3 -legendre pb00.$subj.rest.tcat+orig > outcount.$subj.1D
# polort = the polynomial order of the baseline model

# if ( `1deval -a outcount.$subj.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
#     echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> out.pre_ss_warn.txt
# endif

#================================ despike =================================
## truncate spikes in each voxel's time series:
3dDespike -NEW -nomask -prefix pb00.$subj.rest.despike pb00.$subj.rest.tcat+orig

# ================================= tshift =================================
## slice timing alignment on volumes (default is -time 0)
## 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
3dTshift -tzero 0 -quintic -prefix pb01.$subj.rest.tshift pb00.$subj.rest.despike+orig
## tzero : to interpolate all the slices as though they were all acquired at the beginning of each TR.
## quintic : 5th order of polynomial

# ================================== register and warp ========================
## Registers each 3D sub-brick from the input dataset to the base brick. 'dataset' may contain a sub-brick selector list.
## volume registration (default to third volume):
3dvolreg -verbose -zpad 1 -cubic -base pb01.$subj.rest.tshift+orig'[3]' \
    -1Dfile dfile.$subj.rest.1D -prefix rm.epi.volreg.$subj.rest \
    -1Dmatrix_save mat.$subj.rest.volreg.aff12.1D \
    pb01.$subj.rest.tshift+orig

# ================================== Align EPI with Anatomy ==================================
## align EPI to anatomical datasets or vice versa:
align_epi_anat.py -epi2anat -anat $subj.anat.unifize+orig -anat_has_skull no \
    -epi pb01.$subj.rest.tshift+orig   -epi_base 3 \
    -epi_strip 3dAutomask                                      \
    -suffix _al_junk                     -check_flip           \
    -volreg off    -tshift off           -ginormous_move       \
    -cost nmi      -align_centers yes

## create an all-1 dataset to mask the extents of the warp:
3dcalc -overwrite -a pb01.$subj.rest.tshift_al_junk+orig -expr 'bool(a)' -prefix rm.$subj.epi.all1
## create pb02:
3dcalc -a pb01.$subj.rest.tshift_al_junk+orig -b rm.$subj.epi.all1+orig \
		   -expr 'a*b' -prefix pb02.$subj.rest.volreg

# ================================== Extract Tissue Based Regressors ==================================
## Calculation of motion regressors:
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
           -derivative -collapse_cols euclidean_norm \
           -write $subj.motion_enorm.1D
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
           -demean -write $subj.motion_demean.1D
1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
           -derivative -write $subj.motion_derev.1D

## Transforming the function (“follower datasets”), setting the resolution at 1.719 mm:
@auto_tlrc -apar $subj.anat.unifize+tlrc -input pb02.$subj.rest.volreg+orig -suffix NONE -dxyz 1.719
# ================================== Spatial Blurring ==================================
## Important: blur after tissue based signal extraction
## Otherwise, will get unintended signals in WM and CSF extractions that were blurred in from nearby GM (gray matter)
3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.rest.blur pb02.$subj.rest.volreg+tlrc

## scale each voxel time series to have a mean of 100 (be sure no negatives creep in):
3dTstat -prefix rm.$subj.mean_rest pb03.$subj.rest.blur+tlrc

# ================================== Scaling ==================================
## create a 'brain' mask from. the EPI data (dilate 1 voxel)
3dAutomask -dilate 1 -prefix full_mask.$subj pb03.$subj.rest.blur+tlrc

3dcalc -float -a pb03.$subj.rest.blur+tlrc -b rm.$subj.mean_rest+tlrc -expr 'min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale
