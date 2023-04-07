#!/bin/zsh

thresh_motion=0.4
fwhm=4 # Full width at half maximum

dir_root="/mnt/ext5/SMC/fmri_data"
dir_raw="$dir_root/raw_data/post"

 #for nn in 24 27 29 33 35 36 37 38 40 41 43 45 46 47 48
 #for nn in 12 17 18 19 20 21 22 30 31 32
for nn in 31 32
{
	subj="S$nn"
	dir_output="$dir_root/preproc_data/post/$subj"
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi
	## ======================== Convert ======================== ##
	### ======================== PAR to nii ======================== ###
 #	for img in 'T1' 'FMRI'
 #	{
 #		prefix="$subj.$img"
 #		data_raw=`find $dir_raw -maxdepth 3 -type f -name "${subj}*${img}.PAR"`
 #		dcm2niix_afni -o $dir_output -s y -f $prefix $data_raw
 #		rm $dir_output/*.json
 #	}
 #
 #	mv $dir_output/$prefix.nii $dir_output/${prefix}_t0000.nii
 #	
 #	for t in `seq -f "%04g" 0 2000 598000`
 #	{
 #		t_new=`printf %06d $t`
 #		mv "$dir_output/${prefix}_t$t.nii" "$dir_output/tmp.${prefix}_t$t_new.nii"
 #	}
 #	3dTcat -tr 2 -prefix "$dir_output/$subj.func.nii" "$dir_output/tmp.${prefix}_t*.nii"
 #	
 #	rm $dir_output/tmp*.nii
	### ======================== dcm tp nii ======================== ###
	#### ======================== t1 ======================== ####
 #	dir_data=`find $dir_raw -maxdepth 2 -type d -name "${subj}*T1"`
 #	dcm2niix_afni -f "$subj.T1" -o $dir_output -p y -z n $dir_data
	#### ======================== func ======================== ####
 #	dir_data=`find $dir_raw -maxdepth 2 -type d -name "${subj}*FMRI"`
 #
 #	dir_tmp="$dir_output/tmp"
 #	if [ ! -d $dir_tmp ]; then
 #		mkdir -p -m 755 $dir_tmp
 #	fi
 #	t_new=0
 #	for t_ini in `seq 1 300`
 #		for t in `seq -f "%04g" $t_ini 300 18001`
 #		{
 #			((t_new=$t_new+1))
 #			cp $dir_data/$subj.dcm$t.dcm `printf "$dir_tmp/tmp%05d.dcm" $t_new`
 #		}
 #	dcm2niix_afni -f "$subj.func" -o $dir_output -p y -s y -z n $dir_tmp
 #
 #	rm -rf $dir_tmp
	## ======================== Preprocessing ======================== ##
	cd $dir_output

	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########
	t1="$subj.T1.nii"
	
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
	epi="$subj.func.nii"
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
}
