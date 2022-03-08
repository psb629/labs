#!/bin/tcsh

set list_subj = (S45 S44 S43 S42 S41 S37 S36 S35 S34 S33 S32 S31 S30 S28 S27)

set thresh_motion = 0.4
set fwhm = 4 # Full width at half maximum
set TR = 2
foreach ii (`seq -f "%02g" 1 $#list_subj`)
	set subj = $list_subj[$ii]

	set dir_data = ~/Desktop/preprocessed/$subj/tmp
	#########################################################
	cd $dir_data

	########
	# ANAT # : @auto_tlrc
	########
	# ================================= tlrc coordinate ==================================
	## warp anatomy to standard space, input dataset must be in the current directory:
	@auto_tlrc -base ~/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
	## find attribute WARP_DATA in dataset; -I, invert the transformation:
	cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D
	3dAFNItoNIFTI -prefix anat_final.$subj.nii.gz $subj.anat.unifize+tlrc

	########
	# Func # : lignment (@auto_tlrc)
	########
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
	
	 #3dcalc -float -a pb03.$subj.rest.blur+orig -b rm.$subj.mean_rest+orig -c rm.$subj.epi.all1+orig -expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale
	3dcalc -float -a pb03.$subj.rest.blur+tlrc -b rm.$subj.mean_rest+tlrc -expr 'min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale
end
