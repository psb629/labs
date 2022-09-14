#!/bin/tcsh

set res = 2.683
set fwhm = 4
set thresh_motion = 0.4
set npol = 4

## except: GP16
 #set list_subj = ( GP08 GP09 GP10 GP11 GP17 \
 #				GP18 GP19 GP20 GP21 GP22 \
 #				GP24 GP26 GP27 GP32 GP33 \
 #				GP34 GP35 GP36 GP37 GP38 \
 #				GP39 GP40 GP41 GP42 GP43 \
 #				GP45 GP46 GP47 GP48 GP49 GP50 GP51)
set list_subj = ( GP53 GP54 GP55 )

set list_run = (`count -digits 2 1 3`)

set dir_root = "/mnt/ext6/GP"
set dir_raw = "/mnt/ext6/GP_KJH/fmri_data/raw_data"
# ================================= day1 ================================= #
set day = "day1"
foreach subj ($list_subj)
	set dir_output = "$dir_root/fmri_data/preproc_data/$subj/$day"
	if ( ! -d $dir_output ) then
		mkdir -p -m 755 $dir_output
	endif

	if ( ! -d $dir_raw/$subj/day1 ) then
		continue
	endif

	set MPRAGE = "$dir_raw/$subj/day1/T1*"

	set pname = $dir_output/$subj.MPRAGE
	if ( ! -f $pname+orig.HEAD ) then
		cd $MPRAGE
		Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
		-gert_outdir $dir_output -gert_quit_on_err
		3dWarp -deoblique -prefix $pname $dir_output/temp+orig
		rm $dir_output/temp*
	endif

	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########
	cd $dir_output
	
	set dir_output = "$dir_output/preprocessed"
	if ( ! -d $dir_output ) then
		mkdir -p -m 755 $dir_output
	endif
	# ================================= skull-striping ================================= #
	3dSkullStrip -input $subj.MPRAGE+orig -prefix $dir_output/$subj.anat.ss -orig_vol
	# ================================= unifize ================================= #
	cd $dir_output
	3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5
	# ================================= tlrc ================================= #
	@auto_tlrc -base /usr/local/afni/abin/MNI152_T1_2009c+tlrc -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
	cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.anat.Xat.1D
	if ( ! -f $subj.anat.unifize+tlrc.HEAD ) then
		echo "** missing +tlrc warp dataset: $subj.anat.unifize+tlrc.HEAD"
		exit
	endif
end
# ================================= day2 ================================= #
set day = "day2"
foreach subj ($list_subj)
	set dir_output = "$dir_root/fmri_data/preproc_data/$subj/$day"
	if ( ! -d $dir_output ) then
		mkdir -p -m 755 $dir_output
	endif

	if ( ! -d $dir_raw/$subj/day2 ) then
		continue
	endif

	set dist_PA = "$dir_raw/$subj/day2/DISTORTION_CORR_64CH_INVERT_TO_PA_*"
	set dist_AP = "$dir_raw/$subj/day2/DISTORTION_CORR_64CH_AP_*"
	set r01 = "$dir_raw/$subj/day2/RUN1_*_CMRR_00*"
	set r01_SBREF = "$dir_raw/$subj/day2/RUN1_*_SBREF_00*"
	set r02 = "$dir_raw/$subj/day2/RUN2_*_CMRR_00*"
	set r02_SBREF = "$dir_raw/$subj/day2/RUN2_*_SBREF_00*"
	set r03 = "$dir_raw/$subj/day2/RUN3_*_CMRR_00*"
	set r03_SBREF = "$dir_raw/$subj/day2/RUN3_*_SBREF_00*"

	# ================================= setp 00 : convert ================================= #
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

	cd $r01
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.r01 $dir_output/temp+orig
	rm $dir_output/temp*

	cd $r01_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.r01 $dir_output/temp+orig
	rm $dir_output/temp*

	cd $r02
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.r02 $dir_output/temp+orig
	rm $dir_output/temp*

	cd $r02_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.r02 $dir_output/temp+orig
	rm $dir_output/temp*

	cd $r03
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.r03 $dir_output/temp+orig
	rm $dir_output/temp*

	cd $r03_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.r03 $dir_output/temp+orig
	rm $dir_output/temp*

	# ================================= tcat & tshift ================================= #
	cd $dir_output
	foreach run ($list_run)
		3dTcat -prefix preprocessed/pb00.$subj.r$run.tcat func.$subj.r$run+orig'[0..$]'
	end
	# ================================================================== #
	set dir_output = "$dir_output/preprocessed"
	if ( ! -d $dir_output ) then
		mkdir -p -m 755 $dir_output
	endif
	# ================================= auto block: outcount ================================= #
 	cd $dir_output
 	touch out.pre_ss_warn.txt
 	foreach run ($list_run)
 		3dToutcount -automask -fraction -polort $npol -legendre \
			pb00.$subj.r$run.tcat+orig > outcount.$subj.r$run.1D

 		if ( `1deval -a outcount.$subj.r$run.1D"{0}" -expr "step(a-0.4)"` ) then
 			echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> out.pre_ss_warn.txt
 		endif
 	end
 	# catenate outlier counts into a single time series
 	cat outcount.$subj.r*.1D > outcount_rall.$subj.1D
	# ================================= despike ================================= #
	foreach run ($list_run)
		3dDespike -NEW -nomask -prefix pb00.$subj.r${run}.despike pb00.$subj.r${run}.tcat+orig
	end
	# ================================= tshift ================================= #
	foreach run ($list_run)
		3dTshift -tzero 0 -quintic -prefix pb01.$subj.r${run}.tshift \
		pb00.$subj.r${run}.despike+orig
	end
	# ================================= blip ================================= #
	3dTcat -prefix blip_forward $dir_root/fmri_data/preproc_data/$subj/$day/dist_AP.$subj+orig
	3dTcat -prefix blip_reverse $dir_root/fmri_data/preproc_data/$subj/$day/dist_PA.$subj+orig

	# create median datasets from forward and reverse time series
	3dTstat -median -prefix rm.blip.med.fwd blip_forward+orig
	3dTstat -median -prefix rm.blip.med.rev blip_reverse+orig

	# automask the median datasets
	3dAutomask -apply_prefix rm.blip.med.masked.fwd rm.blip.med.fwd+orig
	3dAutomask -apply_prefix rm.blip.med.masked.rev rm.blip.med.rev+orig

	# compute the midpoint warp between the median datasets
	3dQwarp -plusminus -pmNAMES Rev For                           \
		-pblur 0.05 0.05 -blur -1 -1                          \
		-noweight -minpatch 9                                 \
		-source rm.blip.med.masked.rev+orig                   \
		-base   rm.blip.med.masked.fwd+orig                   \
		-prefix blip_warp

	# warp median datasets (forward and each masked) for QC checks
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
		-source rm.blip.med.fwd+orig                     \
		-prefix blip_med_for

	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig          \
		-source rm.blip.med.masked.fwd+orig              \
		-prefix blip_med_for_masked

	3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig          \
		-source rm.blip.med.masked.rev+orig              \
		-prefix blip_med_rev_masked

	# warp EPI time series data
	foreach run ( $list_run )
		3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig      \
			-source pb01.$subj.r$run.tshift+orig         \
			-prefix pb01.$subj.r$run.blip
	end
	# ================================= align ================================= #
	# - align EPI to anatomical datasets or vice versa
	align_epi_anat.py -anat2epi \
		-anat $dir_root/fmri_data/preproc_data/$subj/day1/preprocessed/$subj.anat.unifize+orig \
		-anat_has_skull no \
		-epi $dir_root/fmri_data/preproc_data/$subj/day2/SBREF.$subj.r02+orig \
		-epi_base 0                                \
		-epi_strip 3dAutomask                                                         \
		-suffix _al_junk                     -check_flip                              \
		-volreg off    -tshift off           -ginormous_move                          \
		-cost lpc+ZZ   -align_centers yes
	# ================================= register and warp ================================= #
	foreach run ($list_run)
		# register each volume to the base
		3dvolreg -verbose -zpad 1 -cubic \
			-base $dir_root/fmri_data/preproc_data/$subj/day2/SBREF.$subj.r02+orig'[0]'\
			-1Dfile dfile.$subj.r$run.1D -prefix rm.epi.volreg.$subj.r$run           \
			-1Dmatrix_save mat.r$run.vr.aff12.1D  \
			pb01.$subj.r$run.blip+orig

		# create an all-1 dataset to mask the extents of the warp
		3dcalc -overwrite -a pb01.$subj.r$run.blip+orig -expr 1 -prefix rm.$subj.epi.all1

		# catenate volreg, epi2anat and tlrc transformations
		cat_matvec -ONELINE $dir_root/fmri_data/preproc_data/$subj/day1/preprocessed/$subj.anat.unifize+tlrc::WARP_DATA \
			-I $subj.anat.unifize_al_junk_mat.aff12.1D \
			-I mat.r$run.vr.aff12.1D > mat.$subj.r$run.warp.aff12.1D

		# apply catenated xform : volreg, epi2anat and tlrc
		3dAllineate -base $dir_root/fmri_data/preproc_data/$subj/day1/preprocessed/$subj.anat.unifize+tlrc \
			-input pb01.$subj.r$run.blip+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-mast_dxyz $res   -prefix rm.epi.nomask.$subj.r$run # $res는 original data의 resolution과 맞춤.

		# warp the all-1 dataset for extents masking
		3dAllineate -base $dir_root/fmri_data/preproc_data/$subj/day1/preprocessed/$subj.anat.unifize+tlrc \
			-input rm.$subj.epi.all1+orig \
			-1Dmatrix_apply mat.$subj.r$run.warp.aff12.1D \
			-final NN -quiet \
			-mast_dxyz $res  -prefix rm.epi.1.$subj.r$run

		# make an extents intersection mask of this run
		3dTstat -min -prefix rm.epi.min.$subj.r$run rm.epi.1.$subj.r$run+tlrc    # -----NEED CHECK-----
	end

	# make a single file of registration params
	cat dfile.$subj.r*.1D > dfile_rall.$subj.1D

	# ----------------------------------------
	# create the extents mask: mask_epi_extents+tlrc
	# (this is a mask of voxels that have valid data at every TR)
	# (only 1 run, so just use 3dcopy to keep naming straight)
	3dcopy rm.epi.min.$subj.r02+tlrc mask_epi_extents.$subj

	# and apply the extents mask to the EPI data
	# (delete any time series with missing data)
	foreach run ($list_run)
		3dcalc -a rm.epi.nomask.$subj.r$run+tlrc -b mask_epi_extents.$subj+tlrc \
			-expr 'a*b' -prefix pb02.$subj.r$run.volreg
	end
	# create an anat_final dataset, aligned with stats
	3dcopy $dir_root/fmri_data/preproc_data/$subj/day1/preprocessed/$subj.anat.unifize+tlrc\
		anat_final.$subj

	# ================================= blur ================================= #
	# blur each volume of each run
	foreach run ($list_run)
		3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.r${run}.blur \
			pb02.$subj.r${run}.volreg+tlrc
	end
	# For each run, blur each volume by a $fwhm mm FWHM (Full Width at Half Max) Gaussian kernel
	# $fwhm -> 4 is default, 6 is common

	# ================================= mask ================================= #
	# create 'full_mask' dataset (union mask)
	# create a 'brain' mask from the EPI data (dilate 1 voxel)

	foreach run ($list_run)
		3dAutomask -dilate 1 -prefix rm.mask_r${run} pb03.$subj.r${run}.blur+tlrc
	end
	# 3dAutomaks  :  Input dataset is EPI 3D+time, or a skull-stripped anatomical. Output dataset is a brain-only mask dataset.
	# -dilate nd  = Dilate the mask outwards 'nd' times.

	# create union of inputs, output type is byte
	3dmask_tool -inputs rm.mask_r*+tlrc.HEAD -union -prefix full_mask.$subj

	# ---- create subject anatomy mask, mask_anat.$subj+tlrc ----
	#      (resampled from tlrc anat). resample은 resolution을 맞춰 sampling을 다시 하는 것. resolution을 낮추면 down sampling하는 것.
	3dresample -master full_mask.$subj+tlrc \
		-input $dir_root/fmri_data/preproc_data/$subj/day1/preprocessed/$subj.anat.unifize+tlrc \
		-prefix rm.resam.anat
	# convert to binary anat mask; fill gaps and holes
	3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj

	# ================================= scale ================================= #
	# scale each voxel time series to have a mean of 100 (be sure no negatives creep in)
	# (subject to a range of [0,200])
	foreach run ($list_run)
		3dTstat -prefix rm.mean_r${run} pb03.$subj.r${run}.blur+tlrc
		3dcalc -float -a pb03.$subj.r${run}.blur+tlrc -b rm.mean_r${run}+tlrc \
			-c mask_epi_extents.$subj+tlrc \
			-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.r${run}.scale
	end
	# ================================= motion regressor ================================= #

	# 1d_tool.py will be used to create a censor file just before 3dDeconvolve

	# -demean : demean each run (new mean of each run = 0.0)
	# -derivative : take the temporal derivative of each vector (done as first backward difference)
	# compute de-meaned motion parameters (for use in regression)
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -demean -write motion_demean.$subj.1D
	# compute motion parameter derivatives (just to have)
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.1D
	# create censor file motion_${subj}_censor.1D, for censoring motion
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}

	# subjA_enorm.1D is the euclidean norm of the derivative, before the extreme mask is applied.
	# -censor_prev_TR : for each censored TR, also censor previous

	foreach run ($list_run)
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1 -demean -write motion_demean.$subj.r${run}.1D
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1 -derivative -demean -write motion_deriv.$subj.r${run}.1D
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1 -show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_{$subj}.r${run}
	end

	# compute motion magnitude time series: the Euclidean norm
	# (sqrt(sum squares)) of the motion parameter derivatives
	1d_tool.py -infile dfile_rall.$subj.1D -set_nruns 1      \
		-derivative  -collapse_cols euclidean_norm      \
		-write motion_{$subj}.eucl_norm.1D

	foreach run ($list_run)
		1d_tool.py -infile dfile.$subj.r${run}.1D -set_nruns 1    \
			-derivative  -collapse_cols euclidean_norm     \
			-write motion_{$subj}.r${run}.eucl_norm.1D
	end
	# ================================= delect temporal files ================================= #
	# delect useless files such as p00 and p01
	cd $dir_output
	rm ./pb00.*.HEAD ./pb00.*.BRIK
	rm ./pb01.*.HEAD ./pb01.*.BRIK
	rm ./rm.*
	# ================================================================== #
	echo "subject $subj completed!"
end
