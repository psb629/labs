#!/bin/tcsh

set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15 38)

set root_dir = /Volumes/T7SSD1
set GA_dir = $root_dir/GA
set GD_dir = $root_dir/GD
set caud_mask_dir = $GA_dir/fMRI_data/roi/GA_caudate_roi/slicer_2/tlrc_resam_fullmask/hem_sep
set mask_dir = $GA_dir/FreeSurfer/03_resam_masks
set output_dir = $GD_dir/connectivity/rest_WM_Vent_BP
# ==========================================================================
if ( ! -d $output_dir ) then
	mkdir -p -m 755 $output_dir
endif
# ==========================================================================
set caudate_list = (head body tail)
# ========================= make the group full-mask =========================
set temp = ()
foreach nn ($subj_list)
	set temp = ($temp $GD_dir/fMRI_data/preproc_data/GD$nn/preprocessed/full_mask.GD$nn+tlrc)
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
	set data_dir = $GD_dir/fMRI_data/preproc_data/GD$nn/preprocessed

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
	set pname = $output_dir/errts.GD$nn.rest
	3dTproject -input $data_dir/pb04.GD$nn.rest.scale+tlrc -prefix $pname+tlrc \
		-mask $gmask.nii.gz -ort $data_dir/roi_pc_Vent_WM.rest -ort $GD_dir/bandpass_regs.1D
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc

	## Calculating seed signals
	foreach cc (`count -digits 1 1 $#caudate_list`)
		set roi = $caudate_list[$cc]
		foreach ss (R L)
			3dmaskave -mask $caud_mask_dir/GA${nn}_${cc}_caudate_${roi}_resam_${ss}+tlrc \
				-quiet $output_dir/errts.GD$nn.rest+tlrc >$output_dir/errts.caudate_${roi}_${ss}.GD$nn.rest.1D
		end
	end
	rm $pname+tlrc.*

	## catenate its to 2D
	set temp = ()
	foreach ss (R L)
		foreach roi ($caudate_list)
			set temp = ($temp $output_dir/errts.caudate_${roi}_${ss}.GD$nn.rest.1D)
		end
	end
	1dcat $temp >$output_dir/errts.caudate.GD$nn.rest.2D
end
#gzip -1v $output_dir/*.BRIK
