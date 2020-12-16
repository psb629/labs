#!/bin/tcsh

set raw_dir = /Volumes/clmnlab/GD/fMRI_data/raw_data
set preproc_dir = /Volumes/T7SSD1/GD/fMRI_data/preproc_data

#set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15 GD38)
set subj_list = (GD38)

## variables for tcat tshift ##
set res = 2.683 # Using minimum spacing of 2.682927 mm for new grid spacing
set fwhm = 4
set thresh_motion = 0.4
set npol = 4

foreach subj ($subj_list)
    ## combine rest IMA files ##
    set root_dir = $preproc_dir/$subj
	if (! -d $root_dir ) then
    	mkdir -p -m 755 $root_dir
	endif

	cd $raw_dir/$subj/rest
	Dimon -infile_pat "*.IMA" -gert_create_dataset -gert_to3d_prefix ttemp \
		-gert_outdir $root_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $root_dir/func.$subj.rest $root_dir/ttemp+orig
	rm $root_dir/ttemp*
	
	cd $root_dir/preprocessed

	## run tcat tshift ##
	3dTcat -prefix pb00.$subj.rest.tcat $root_dir/func.$subj.rest+orig'[0..$]'

	## outlier count ##
	touch out.pre_ss_warn.txt
	3dToutcount -automask -fraction -polort $npol -legendre pb00.$subj.rest.tcat+orig > outcount.$subj.rest.1D

	if ( `1deval -a outcount.$subj.rest.1D"{0}" -expr "step(a-0.4)"` ) then
		echo "** TR #0 outliers: possible pre-steady state TRs in rest" >> out.pre_ss_warn.txt
	endif

	# despike
	3dDespike -NEW -nomask -prefix pb00.$subj.rest.despike pb00.$subj.rest.tcat+orig

	# shift
	3dTshift -tzero 0 -quintic -prefix pb01.$subj.rest.tshift pb00.$subj.rest.despike+orig

	## blip ##
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig \
		-source pb01.$subj.rest.tshift+orig \
		-prefix pb01.$subj.rest.blip

	## align to volume registration (volreg) ##
	# register each volume to the base
	3dvolreg -verbose -zpad 1 -cubic -base $root_dir/SBREF.$subj.r04+orig'[0]' \
		-1Dfile dfile.$subj.rest.1D -prefix rm.epi.volreg.$subj.rest \
		-1Dmatrix_save mat.rest.vr.aff12.1D \
		pb01.$subj.rest.blip+orig

	# create an all-1 dataset to mask the extents of the warp
	3dcalc -overwrite -a pb01.$subj.rest.blip+orig -expr 1 -prefix rm.$subj.epi.all1

	# catenate volreg, epi2anat and tlrc transformations
	cat_matvec -ONELINE $subj.UnisSanat+tlrc::WARP_DATA \
		-I $subj.UnisSanat_al_junk_mat.aff12.1D \
		-I mat.rest.vr.aff12.1D > mat.$subj.rest.warp.aff12.1D

	# apply catenated xform : volreg, epi2anat and tlrc
	# 3dAllineate : Program to align one dataset (the 'source') to a base dataset.
	3dAllineate -base $subj.UnisSanat+tlrc \
		-input pb01.$subj.rest.blip+orig \
		-1Dmatrix_apply mat.$subj.rest.warp.aff12.1D \
		-mast_dxyz $res -prefix rm.epi.nomask.$subj.rest

	# warp the all-1 dataset for extents masking
	3dAllineate -base $subj.UnisSanat+tlrc \
		-input rm.$subj.epi.all1+orig \
		-1Dmatrix_apply mat.$subj.rest.warp.aff12.1D \
		-final NN -quiet \
		-mast_dxyz $res -prefix rm.epi.1.$subj.rest

	# make an extents intersection mask of this run
	3dTstat -min -prefix rm.epi.min.$subj.rest rm.epi.1.$subj.rest+tlrc    # -----NEED CHECK-----

	# create the extents mask: mask_epi_extents+tlrc
	# (this is a mask of voxels that have valid data at every TR)
	# (only 1 run, so just use 3dcopy to keep naming straight)
	3dcalc -a rm.epi.nomask.$subj.rest+tlrc \
		-b mask_epi_extents.$subj+tlrc \
		-expr 'a*b' -prefix pb02.$subj.rest.volreg

	## blur and scale ##
	3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.rest.blur pb02.$subj.rest.volreg+tlrc

	# 3dAutomask -dilate 1 -prefix rm.mask_rest pb03.$subj.rest.blur+tlrc
	# 3dmask_tool -inputs rm.mask_rest+tlrc.HEAD -union -prefix rest_mask.$subj
	# 3dresample -master rest_mask.$subj+tlrc -input $subj.UnisSanat+tlrc -prefix rm.resam.anat
	# 3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj

	3dTstat -prefix rm.mean_rest pb03.$subj.rest.blur+tlrc
	3dcalc -float -a pb03.$subj.rest.blur+tlrc -b rm.mean_rest+tlrc \
		-c mask_epi_extents.$subj+tlrc \
		-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.$subj.rest.scale

	## motion ##
	# -demean : demean each run (new mean of each run = 0.0)
	# -derivative : take the temporal derivative of each vector (done as first backward difference)
	# compute de-meaned motion parameters (for use in regression)
	1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
		-demean -write motion_demean.1D

	# compute motion parameter derivatives (just to have)
	1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
	-derivative -write motion_deriv.1D

	# create censor file motion_${subj}_censor.1D, for censoring motion
	1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
		-show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_$subj.rest

	# compute motion magnitude time series: the Euclidean norm
	# (sqrt(sum squares)) of the motion parameter derivatives
	1d_tool.py -infile dfile.$subj.rest.1D -set_nruns 1 \
		-derivative -collapse_cols euclidean_norm \
		-write motion_$subj.rest.eucl_norm.1D
	
	# ==================================================================
	# ================== delect p00, p01, and rm ===================
	# delect useless files such as p00, p01, and rm
	rm ./pb00.*.HEAD ./pb00.*.BRIK
	rm ./pb01.*.HEAD ./pb01.*.BRIK
	rm ./rm.*
	# ================== gzip ================== #
	cd $root_dir
	gzip -1v *.BRIK

	cd ./preprocessed
	gzip -1v *.BRIK
	# ==================================================================
	echo "subject $subj completed!"

end
