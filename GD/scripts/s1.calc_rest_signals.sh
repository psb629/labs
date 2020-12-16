#!/bin/tcsh

set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15 38)

set root_dir = /Volumes/T7SSD1
set caud_mask_dir = $root_dir/GA/fMRI_data/roi/GA_caudate_roi/slicer_2/tlrc_resam_fullmask/hem_sep
set mask_dir = $root_dir/GA/FreeSurfer/03_resam_masks
set output_dir = $root_dir/GD/connectivity/rest_WM_Vent_BP
# ==========================================================================
if ( ! -d $output_dir ) then
	mkdir -p -m 755 $output_dir
endif
# ========================= make the group full-mask =========================
set temp = ()
foreach nn ($subj_list)
	set temp = ($temp $root_dir/GD/fMRI_data/preproc_data/GD$nn/preprocessed/full_mask.GD$nn+tlrc.HEAD)
end
set gmask = $output_dir/full_mask.GDs.n$#subj_list
if ( -e $gmask.nii.gz ) then
	rm $gmask+tlrc.* $gmask.nii.gz
endif
3dMean -mask_inter -prefix $gmask $temp
3dAFNItoNIFTI -prefix $gmask.nii.gz $gmask+tlrc
rm $gmask+tlrc.*
# ==========================================================================
foreach nn ($subj_list)
	set data_dir = $root_dir/GD/fMRI_data/preproc_data/GD$nn/preprocessed

	## 
	set fin_output = $data_dir/roi_pc_Vent_WM.rest
	if (! -e $fin_output) then
		3dDetrend -polort 4 -prefix $data_dir/rm.det_pcin_rest $data_dir/pb04.GD$nn.rest.scale+tlrc
		set ktrs = `1d_tool.py -infile $data_dir/motion_GD$nn.rest_censor.1D -show_trs_uncensored encoded`
		3dpc -mask $mask_dir/GA{$nn}_wm_resam_subcud+tlrc -pcsave 5 -prefix $data_dir/roi_pc_WM_subcud.rest $data_dir/rm.det_pcin_rest+tlrc"[$ktrs]"
		1d_tool.py -censor_fill_parent $data_dir/motion_GD$nn.rest_censor.1D -infile $data_dir/roi_pc_WM_subcud.rest_vec.1D -write $data_dir/roi_pc_WM_subcud_noc.rest
		3dpc -mask $mask_dir/GA{$nn}_ventricles_resam+tlrc -pcsave 5 -prefix $data_dir/roi_pc_Ventricles.rest $data_dir/rm.det_pcin_rest+tlrc"[$ktrs]"
		1d_tool.py -censor_fill_parent $data_dir/motion_GD$nn.rest_censor.1D -infile $data_dir/roi_pc_Ventricles.rest_vec.1D -write $data_dir/roi_pc_Ventricles_noc.rest
		1dcat $data_dir/roi_pc_Ventricles_noc.rest $data_dir/roi_pc_WM_subcud_noc.rest >$data_dir/roi_pc_Vent_WM.rest
	endif

	##
	3dTproject -input $data_dir/pb04.GD$nn.rest.scale+tlrc -prefix $output_dir/errts.GD$nn.rest+tlrc \
		-mask $gmask.nii.gz -ort $data_dir/roi_pc_Vent_WM.rest  -ort $root_dir/GD/bandpass_regs.1D

	## Calculating seed signals
	3dmaskave -mask $caud_mask_dir/GA${nn}_1_caudate_head_resam_R+tlrc -quiet $output_dir/errts.GD$nn.rest+tlrc >$output_dir/errts.caudate_head_R.GD$nn.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${nn}_2_caudate_body_resam_R+tlrc -quiet $output_dir/errts.GD$nn.rest+tlrc >$output_dir/errts.caudate_body_R.GD$nn.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${nn}_3_caudate_tail_resam_R+tlrc -quiet $output_dir/errts.GD$nn.rest+tlrc >$output_dir/errts.caudate_tail_R.GD$nn.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${nn}_1_caudate_head_resam_L+tlrc -quiet $output_dir/errts.GD$nn.rest+tlrc >$output_dir/errts.caudate_head_L.GD$nn.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${nn}_2_caudate_body_resam_L+tlrc -quiet $output_dir/errts.GD$nn.rest+tlrc >$output_dir/errts.caudate_body_L.GD$nn.rest.1D
	3dmaskave -mask $caud_mask_dir/GA${nn}_3_caudate_tail_resam_L+tlrc -quiet $output_dir/errts.GD$nn.rest+tlrc >$output_dir/errts.caudate_tail_L.GD$nn.rest.1D

 #	3dmaskave -mask $output_dir/cdh_L_GB-GA+tlrc -quiet errts.GA$nn.rest+tlrc > errts.cdh_L_GB-GA.GA$nn.rest.1D
 #	3dmaskave -mask $output_dir/cdt_L_GB-GA+tlrc -quiet errts.GA$nn.rest+tlrc > errts.cdt_L_GB-GA.GA$nn.rest.1D
 #	3dmaskave -mask $output_dir/cdh_R_GB-GA+tlrc -quiet errts.GA$nn.rest+tlrc > errts.cdh_R_GB-GA.GA$nn.rest.1D
 #	3dmaskave -mask $output_dir/cdt_R_GB-GA+tlrc -quiet errts.GA$nn.rest+tlrc > errts.cdt_R_GB-GA.GA$nn.rest.1D
 #	3dmaskave -mask $output_dir/cdh_L_GA+tlrc -quiet errts.GA$nn.rest+tlrc > errts.cdh_L_GA.GA$nn.rest.1D
 #	3dmaskave -mask $output_dir/cdt_L_GB+tlrc -quiet errts.GA$nn.rest+tlrc > errts.cdt_L_GB.GA$nn.rest.1D
 #	3dmaskave -mask $output_dir/cdt_R_GB+tlrc -quiet errts.GA$nn.rest+tlrc > errts.cdt_R_GB.GA$nn.rest.1D
	1dcat $output_dir/errts.caudate_head_R.GD$nn.rest.1D \
		$output_dir/errts.caudate_body_R.GD$nn.rest.1D \
		$output_dir/errts.caudate_tail_R.GD$nn.rest.1D \
		$output_dir/errts.caudate_head_L.GD$nn.rest.1D \
		$output_dir/errts.caudate_body_L.GD$nn.rest.1D \
		$output_dir/errts.caudate_tail_L.GD$nn.rest.1D \
 #		errts.cdh_L_GB-GA.GA$nn.rest.1D \
 #		errts.cdt_L_GB-GA.GA$nn.rest.1D \
 #		errts.cdh_R_GB-GA.GA$nn.rest.1D \
 #		errts.cdt_R_GB-GA.GA$nn.rest.1D \
 #		errts.cdh_L_GA.GA$nn.rest.1D \
 #		errts.cdt_L_GB.GA$nn.rest.1D \
 #		errts.cdt_R_GB.GA$nn.rest.1D \
		>$output_dir/errts.caudate.GD$nn.rest.2D
end
gzip -1v $output_dir/*.BRIK
