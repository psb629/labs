#!/bin/tcsh
set root_dir = 
set caud_mask_dir = /Volumes/T7SSD1/GA/fMRI_data/masks/GA_caudate_roi/slicer_2/tlrc_resam_fullmask/hem_sep
set mask_dir = /Volumes/T7SSD1/GA/FreeSurfer/03_resam_masks
set output_dir = /Volumes/T7SSD1/GD/connectivity/rest_WM_Vent_BP
set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15)

foreach num ($subj_list)
	set data_dir = /Volumes/T7SSD1/GD/fMRI_data/preproc_data/GD$num/preprocessed
	cd $data_dir
	3dDetrend -polort 4 -prefix rm.det_pcin_rest pb04.GD$num.rest.scale+tlrc
	set ktrs = `1d_tool.py -infile motion_GD$num.rest_censor.1D -show_trs_uncensored encoded`
	3dpc -mask $mask_dir/GA{$num}_wm_resam_subcud+tlrc -pcsave 5 -prefix roi_pc_WM_subcud.rest rm.det_pcin_rest+tlrc"[$ktrs]"
	1d_tool.py -censor_fill_parent motion_GD$num.rest_censor.1D -infile roi_pc_WM_subcud.rest_vec.1D -write roi_pc_WM_subcud_noc.rest
	3dpc -mask $mask_dir/GA{$num}_ventricles_resam+tlrc -pcsave 5 -prefix roi_pc_Ventricles.rest rm.det_pcin_rest+tlrc"[$ktrs]"
	1d_tool.py -censor_fill_parent motion_GD$num.rest_censor.1D -infile roi_pc_Ventricles.rest_vec.1D -write roi_pc_Ventricles_noc.rest
	1dcat roi_pc_Ventricles_noc.rest roi_pc_WM_subcud_noc.rest > roi_pc_Vent_WM.rest

	3dTproject -input pb04.GD$num.rest.scale+tlrc -prefix $output_dir/errts.GD$num.rest+tlrc \
		-mask /Volumes/T7SSD1/GD/fMRI_data/masks/full/full_mask.GDs_n14.nii.gz -ort roi_pc_Vent_WM.rest  -ort /Volumes/T7SSD1/GD/bandpass_regs.1D

	cd $output_dir

	## Calculating seed signals
	3dmaskave -mask $caud_mask_dir/GA${num}_1_caudate_head_resam_R+tlrc -quiet errts.GD$num.rest+tlrc > errts.caudate_head_R.GD$num.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${num}_2_caudate_body_resam_R+tlrc -quiet errts.GD$num.rest+tlrc > errts.caudate_body_R.GD$num.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${num}_3_caudate_tail_resam_R+tlrc -quiet errts.GD$num.rest+tlrc > errts.caudate_tail_R.GD$num.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${num}_1_caudate_head_resam_L+tlrc -quiet errts.GD$num.rest+tlrc > errts.caudate_head_L.GD$num.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${num}_2_caudate_body_resam_L+tlrc -quiet errts.GD$num.rest+tlrc > errts.caudate_body_L.GD$num.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${num}_3_caudate_tail_resam_L+tlrc -quiet errts.GD$num.rest+tlrc > errts.caudate_tail_L.GD$num.rest.1D

 #	3dmaskave -mask $output_dir/cdh_L_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdh_L_GB-GA.GA$num.rest.1D
 #	3dmaskave -mask $output_dir/cdt_L_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_L_GB-GA.GA$num.rest.1D
 #	3dmaskave -mask $output_dir/cdh_R_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdh_R_GB-GA.GA$num.rest.1D
 #	3dmaskave -mask $output_dir/cdt_R_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_R_GB-GA.GA$num.rest.1D
 #	3dmaskave -mask $output_dir/cdh_L_GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdh_L_GA.GA$num.rest.1D
 #	3dmaskave -mask $output_dir/cdt_L_GB+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_L_GB.GA$num.rest.1D
 #	3dmaskave -mask $output_dir/cdt_R_GB+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_R_GB.GA$num.rest.1D
	1dcat errts.caudate_head_R.GD$num.rest.1D \
		errts.caudate_body_R.GD$num.rest.1D \
		errts.caudate_tail_R.GD$num.rest.1D \
		errts.caudate_head_L.GD$num.rest.1D \
		errts.caudate_body_L.GD$num.rest.1D \
		errts.caudate_tail_L.GD$num.rest.1D \
 #		errts.cdh_L_GB-GA.GA$num.rest.1D \
 #		errts.cdt_L_GB-GA.GA$num.rest.1D \
 #		errts.cdh_R_GB-GA.GA$num.rest.1D \
 #		errts.cdt_R_GB-GA.GA$num.rest.1D \
 #		errts.cdh_L_GA.GA$num.rest.1D \
 #		errts.cdt_L_GB.GA$num.rest.1D \
 #		errts.cdt_R_GB.GA$num.rest.1D \
		> errts.caudate.GD$num.rest.2D
end
gzip -1v $output_dir/*.BRIK
