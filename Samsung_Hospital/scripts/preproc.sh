#!/bin/tcsh

set subj_list = (S27 S28)
set date_list = (210615 210615)
set coord = orig

foreach ii (`seq -f "%02g" 1 2`)
	set subj = $subj_list[$ii]
	set date = $date_list[$ii]

	set data_dir = ~/Desktop/${subj}_${date}_MRI
 #	set output_dir = /Volumes/T7SSD1/samsung_hospital/fmri_data/preproc_data/$subj
	set output_dir = ~/Desktop/$subj
	if ( ! -d $output_dir/preprocessed ) then
		mkdir -p -m 755 $output_dir/preprocessed
	endif
	set epi = $output_dir/${subj}_fMRI.nii.gz
	set t1 = $output_dir/${subj}_T1.nii.gz
	#########################################################
	## convert dcm files into NIFTI files, written by Sungbeen Park
	
	# ========================= T1 data : 366 files =========================
	if ( ! -f $t1 ) then
		set raw_T1 = $data_dir/${subj}_${date}_T1
		dcm2niix_afni -o $output_dir -s y -z y -f "${subj}_T1" $raw_T1
		rm $output_dir/*.json
		# added the line since S19, because of the unexpected suffix "_real"
		mv $output_dir/${subj}_T1*.nii.gz $t1
	endif
	# ========================= fMRI data : 18001 files =========================
	if ( ! -f $epi ) then
		set raw_fMRI = $data_dir/${subj}_${date}_FMRI
		set TR = 2
		
		set cnt = 0
		set set_time = `seq 1 300`
		foreach t_ini ($set_time)
			set set_data = `seq -f "%04g" $t_ini 300 18001`
			foreach n ($set_data)
				@ cnt = $cnt + 1
				set n_prime = `printf %05d $cnt`
				cp $raw_fMRI/$subj.dcm$n.dcm $output_dir/temp$n_prime.dcm
			end
			set t = `printf %03d $t_ini`
			dcm2niix_afni -o $output_dir -s y -z y -f "${subj}_func$t" $output_dir
			rm $output_dir/*.dcm
		end
		3dTcat -tr $TR -prefix $output_dir/temp $output_dir/${subj}_func*.nii.gz
		rm $output_dir/${subj}_func*.nii.gz
		3dAFNItoNIFTI -prefix $epi $output_dir/temp+orig
		rm $output_dir/*.json $output_dir/temp+orig.*
		## added the line since S19, because of the unexpected suffix "_real"
	endif
	# ========================= DTI data : 3221 files =========================
	set raw_DTI = $data_dir/${subj}_${date}_dti
	
	#########################################################
	set thresh_motion = 0.4
	set fwhm = 4 # Full width at half maximum
	
	set output_dir = $output_dir/preprocessed
	
	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########
	cd $output_dir
	
	3dcopy $t1 $subj.anat+orig
	 #3dWarp -deoblique -prefix $subj.anat.deoblique $subj.anat+orig > deoblique.$subj.aff.2D
	
	# ================ change the orientation of a dataset ================
	## 'LPI' means an one of the 'neurcoscience' orientation, where the x-axis is Left-to-Right, the y-axis is Posterior-to-Anterior, and the z-axis is Inferior-to-Superior:
	 #3dresample -orient LPI -prefix $subj.anat.lpi -input $subj.anat.deoblique+orig
	3dresample -orient LPI -prefix $subj.anat.lpi -input $subj.anat+orig
	
	# ================================= skull-striping =================================
	## unifize -> ss : S23 has a problem with cutting brain
	3dSkullStrip -input $subj.anat.lpi+orig -prefix $subj.anat.ss -orig_vol
	# ================================= unifize =================================
	## this program can be a useful step to take BEFORE 3dSkullStrip, since the latter program can fail if the input volume is strongly shaded -- 3dUnifize will (mostly) remove such shading artifacts.
	3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5
	
	cd $output_dir
	# ================================= tlrc coordinate ==================================
	if ($coord == tlrc) then
		## warp anatomy to standard space, input dataset must be in the current directory:
		@auto_tlrc -base ~/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
		## find attribute WARP_DATA in dataset; -I, invert the transformation:
		cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D
		3dAFNItoNIFTI -prefix anat_final.$subj.nii.gz $subj.anat.unifize+tlrc
	endif
	
	########
	# Func # : Despiking (3dDespike) -> Slice Timing Correction (3dTshift) -> Motion Correct EPI (3dvolreg)
	########  -> Alignment (@auto_tlrc) -> Spatial Blurring -> Nuisance Regression -> Scaling
	cd $output_dir
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
	
	cd $output_dir
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
	
	cd $output_dir
	if ($coord == tlrc) then
		## Transforming the function (“follower datasets”), setting the resolution at 1.719 mm:
		@auto_tlrc -apar $subj.anat.unifize+tlrc -input pb02.$subj.rest.volreg+orig -suffix NONE -dxyz 1.719
	endif
	# ================================== Spatial Blurring ==================================
	## Important: blur after tissue based signal extraction
	## Otherwise, will get unintended signals in WM and CSF extractions that were blurred in from nearby GM (gray matter)
	3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.rest.blur pb02.$subj.rest.volreg+${coord}
	
	## scale each voxel time series to have a mean of 100 (be sure no negatives creep in):
	3dTstat -prefix rm.$subj.mean_rest pb03.$subj.rest.blur+${coord}
	
	# ================================== Scaling ==================================
	## create a 'brain' mask from. the EPI data (dilate 1 voxel)
	3dAutomask -dilate 1 -prefix full_mask.$subj pb03.$subj.rest.blur+${coord}
	
	 #3dcalc -float -a pb03.$subj.rest.blur+orig -b rm.$subj.mean_rest+orig -c rm.$subj.epi.all1+orig -expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale
	3dcalc -float -a pb03.$subj.rest.blur+${coord} -b rm.$subj.mean_rest+${coord} -expr 'min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale
end
