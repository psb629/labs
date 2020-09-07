#!/bin/tcsh

# ================================= step01 : tcat & tshift =================================
	# ================================= tcat (pb00) =================================
	# tcat은 각 시간의 volume(sub-brick) 데이터를 시간에 대해 catenate 해준다는 뜻. 시간을 포함한 4차원 데이터로 merge.
	# apply 3dTcat to copy input dsets to results dir, while
	# removing the first 0 TRs
	foreach run ($runs)
		3dTcat -prefix $output_dir/pb00.$subj.r$run.tcat func.$subj.r$run+orig'[0..$]'
	end
	# if you want to remove the first 2 TRs (TR indices 0 and 1), use [2..$] instead of [0..$]
	# 2..$ -> $는 just a variable which means the very end of that array. Only keeping volumes two to the very end 라는 뜻.

	# enter the results directory (can begin processing data)
	cd $output_dir

	3dcopy $subj_preproc_dir/$subj.MPRAGE+orig $subj.anat+orig
	# Will copy only the dataset with the given view (orig, acpc, tlrc).

	
	# MOLLY ADDED ================================ despike =================================
	# apply 3dDespike to each run
	# Removes 'spikes' from the 3D+time input dataset and writes a new dataset with the spike values replaced by something
	# more pleasing to the eye.
	foreach run ($runs)
		3dDespike -NEW -nomask -prefix pb00.$subj.r${run}.despike pb00.$subj.r${run}.tcat+orig
	end
	# -NEW  = Use the 'new' method for computing the fit, which should be faster than the L1 method for long time
	# series (200+ time points); however, the results are similar but NOT identical. [29 Nov 2013]
	# -nomask  = Process all voxels
	# -prefix -> tells me what to label the output of the file and the command is done


	# ================================= tshift (pb01) =================================
	# t shift or slice time correction
	# time shift data so all slice timing is the same
	# 데이터를 얻는(slicing) 시간이 각각의 axial voxel에 대해 다르기 때문에 보정해주는 것.
	foreach run ($runs)
		3dTshift -tzero 0 -quintic -prefix pb01.$subj.r${run}.tshift \
		pb00.$subj.r${run}.despike+orig
	end
	# tzero -> to interpolate all the slices as though they were all acquired at the beginning of each TR.
	# quintic -> 5th order of polynomial
	

	# ==================================================================
	# warp EPI time series data
	foreach run ( $runs )
		3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig      \
			-source pb01.$subj.r$run.tshift+orig         \
			-prefix pb01.$subj.r$run.blip
	end
	# ==================================================================


	# ================================== step03 : volreg ==================================
	# ================================= align ==================================
	# for e2a: compute anat alignment transformation to EPI registration base
	# (new anat will be intermediate, stripped, epi_$subjID.anat_ns+orig)

	# 3dSkullStrip -input VOL -prefix VOL_PREFIX
	3dSkullStrip -input $subj.anat+orig -prefix $subj.sSanat -orig_vol
	3dUnifize -input $subj.sSanat+orig -prefix $subj.UnisSanat -GM

	# - align EPI to anatomical datasets or vice versa
	align_epi_anat.py -anat2epi -anat $subj.UnisSanat+orig -anat_has_skull no    \
		-epi $subj_preproc_dir/SBREF.$subj.r04+orig   -epi_base 0                                \
		-epi_strip 3dAutomask                                                         \
		-suffix _al_junk                     -check_flip                              \
		-volreg off    -tshift off           -ginormous_move                          \
		-cost lpa      -align_centers yes
		# -cost nmi : weired result in the multiband8 protocol
		# -cost lpa (local pearson correlation)


	# ================================== tlrc ==================================
	# warp anatomy to standard space
	#@auto_tlrc -base TT_N27+tlrc -input $subj.UnisSanat+orig -no_ss
	@auto_tlrc -base MNI152_T1_2009c+tlrc.HEAD -input $subj.UnisSanat+orig -no_ss -init_xform AUTO_CENTER #-init_xform AUTO_CENTER

	cat_matvec $subj.UnisSanat+tlrc::WARP_DATA -I > warp.anat.Xat.1D

	if ( ! -f $subj.UnisSanat+tlrc.HEAD ) then
		echo "** missing +tlrc warp dataset: $subj.UnisSanat+tlrc.HEAD"
		exit
	endif


	# ================================== register and warp (pb02) ========================
	foreach run ($runs)
		# register each volume to the base
		3dvolreg -verbose -zpad 1 -cubic -base $subj_preproc_dir/SBREF.$subj.r04+orig'[0]'         \
			-1Dfile dfile.$subj.r$run.1D -prefix rm.epi.volreg.$subj.r$run           \
			-1Dmatrix_save mat.r$run.vr.aff12.1D  \
			pb01.$subj.r$run.blip+orig

		# create an all-1 dataset to mask the extents of the warp
		3dcalc -overwrite -a pb01.$subj.r$run.blip+orig -expr 1 -prefix rm.$subj.epi.all1

		# catenate volreg, epi2anat and tlrc transformations
		cat_matvec -ONELINE $subj.UnisSanat+tlrc::WARP_DATA -I $subj.UnisSanat_al_junk_mat.aff12.1D -I \
			mat.r$run.vr.aff12.1D > mat.$subj.r$run.warp.aff12.1D

		# apply catenated xform : volreg, epi2anat and tlrc
		3dAllineate -base $subj.UnisSanat+tlrc \
			-input pb01.$subj.r$run.blip+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-mast_dxyz $res   -prefix rm.epi.nomask.$subj.r$run # $res는 original data의 resolution과 맞춤.

		# warp the all-1 dataset for extents masking
		3dAllineate -base $subj.UnisSanat+tlrc \
			-input rm.$subj.epi.all1+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-final NN -quiet \
			-mast_dxyz $res  -prefix rm.epi.1.$subj.r$run

		# make an extents intersection mask of this run
		3dTstat -min -prefix rm.epi.min.$subj.r$run rm.epi.1.$subj.r$run+tlrc    # -----NEED CHECK-----
	end


	# ----------------------------------------
	# create the extents mask: mask_epi_extents+tlrc
	# (this is a mask of voxels that have valid data at every TR)
	# (only 1 run, so just use 3dcopy to keep naming straight)
	3dcopy rm.epi.min.$subj.r04+tlrc mask_epi_extents.$subj

	# and apply the extents mask to the EPI data
	# (delete any time series with missing data)
	foreach run ($runs)
		3dcalc -a rm.epi.nomask.$subj.r$run+tlrc -b mask_epi_extents.$subj+tlrc \
			-expr 'a*b' -prefix pb02.$subj.r$run.volreg
	end

	# create an anat_final dataset, aligned with stats
	3dcopy $subj.UnisSanat+tlrc anat_final.$subj

	# warp anat follower datasets (affine)     - skull 있는 데이터를 warp하는 목적
	3dAllineate -source $subj.anat+orig \
		-master anat_final.$subj+tlrc \
		-final wsinc5 -1Dmatrix_apply warp.anat.Xat.1D \
		-prefix anat_w_skull_warped.$subj
