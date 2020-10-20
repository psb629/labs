set rootdir =  /Volumes/clmnlab/GA
set caud_mask_dir = $rootdir/fmri_data/GA_caudate_ROI/slicer_2/tlrc_resam_fullmask/hem_sep
set mask_dir = $rootdir/FreeSurfer/03_resam_masks
set output_dir = $rootdir/Connectivity/result/rest_WM_Vent_BP
set numlist = (01 02 05 07 08 11 12 13 14 15 18 19 20 21 23 26 27 28 29 30 31 32 33 34 35 36 37 38 42 44)
set run = 'est'
foreach num ($numlist)
                set data_dir = $rootdir/Connectivity/data/rest_preproc/GA$num
                cd $data_dir
                3dDetrend -polort 4 -prefix rm.det_pcin_r$run pb04.GA$num.r$run.scale+tlrc
                set ktrs = `1d_tool.py -infile motion_GA$num.r{$run}_censor.1D -show_trs_uncensored encoded`
                3dpc -mask $mask_dir/GA{$num}_wm_resam_subcud+tlrc -pcsave 5 -prefix roi_pc_WM_subcud.r$run rm.det_pcin_r$run+tlrc"[$ktrs]"
                1d_tool.py -censor_fill_parent motion_GA$num.r{$run}_censor.1D -infile roi_pc_WM_subcud.r{$run}_vec.1D -write roi_pc_WM_subcud_noc.rest
                3dpc -mask $mask_dir/GA{$num}_ventricles_resam+tlrc -pcsave 5 -prefix roi_pc_Ventricles.r$run rm.det_pcin_r$run+tlrc"[$ktrs]"
                1d_tool.py -censor_fill_parent motion_GA$num.r{$run}_censor.1D -infile roi_pc_Ventricles.r{$run}_vec.1D -write roi_pc_Ventricles_noc.rest
                1dcat roi_pc_Ventricles_noc.rest roi_pc_WM_subcud_noc.rest > roi_pc_Vent_WM.rest
                3dTproject -input pb04.GA$num.r$run.scale+tlrc -prefix $output_dir/errts.GA$num.rest+tlrc \
                -mask $rootdir/Connectivity/mask/full_mask_GAGB_n30+tlrc -ort roi_pc_Vent_WM.rest  -ort $rootdir/bandpass_regs.1D

                cd $output_dir

                ## Calculating seed signals
                 3dmaskave -mask $caud_mask_dir/{GA$num}_1_caudate_head_resam_R+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_head_R.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_2_caudate_body_resam_R+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_body_R.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_3_caudate_tail_resam_R+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_tail_R.GA$num.rest.1D

                 3dmaskave -mask $caud_mask_dir/{GA$num}_1_caudate_head_resam_L+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_head_L.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_2_caudate_body_resam_L+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_body_L.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_3_caudate_tail_resam_L+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_tail_L.GA$num.rest.1D

                 3dmaskave -mask $output_dir/cdh_L_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdh_L_GB-GA.GA$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_L_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_L_GB-GA.GA$num.rest.1D
                 3dmaskave -mask $output_dir/cdh_R_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdh_R_GB-GA.GA$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_R_GB-GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_R_GB-GA.GA$num.rest.1D
                 3dmaskave -mask $output_dir/cdh_L_GA+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdh_L_GA.GA$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_L_GB+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_L_GB.GA$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_R_GB+tlrc -quiet errts.GA$num.rest+tlrc > errts.cdt_R_GB.GA$num.rest.1D
                 1dcat errts.caudate_head_R.GA$num.rest.1D \
                      errts.caudate_body_R.GA$num.rest.1D \
                      errts.caudate_tail_R.GA$num.rest.1D \
                      errts.caudate_head_L.GA$num.rest.1D \
                      errts.caudate_body_L.GA$num.rest.1D \
                      errts.caudate_tail_L.GA$num.rest.1D \
                      errts.cdh_L_GB-GA.GA$num.rest.1D \
                      errts.cdt_L_GB-GA.GA$num.rest.1D \
                      errts.cdh_R_GB-GA.GA$num.rest.1D \
                      errts.cdt_R_GB-GA.GA$num.rest.1D \
                      errts.cdh_L_GA.GA$num.rest.1D \
                      errts.cdt_L_GB.GA$num.rest.1D \
                      errts.cdt_R_GB.GA$num.rest.1D \
                      > errts.caudate.GA$num.rest.2D

                set data_dir = $rootdir/Connectivity/data/rest_preproc/GB$num
                cd $data_dir
                3dDetrend -polort 4 -prefix rm.det_pcin_r$run pb04.GA$num.r$run.scale+tlrc
                set ktrs = `1d_tool.py -infile motion_GA$num.r{$run}_censor.1D -show_trs_uncensored encoded`
                3dpc -mask $mask_dir/GA{$num}_wm_resam_subcud+tlrc -pcsave 5 -prefix roi_pc_WM_subcud.r$run rm.det_pcin_r$run+tlrc"[$ktrs]"
                1d_tool.py -censor_fill_parent motion_GA$num.r{$run}_censor.1D -infile roi_pc_WM_subcud.r{$run}_vec.1D -write roi_pc_WM_subcud_noc.rest
                3dpc -mask $mask_dir/GA{$num}_ventricles_resam+tlrc -pcsave 5 -prefix roi_pc_Ventricles.r$run rm.det_pcin_r$run+tlrc"[$ktrs]"
                1d_tool.py -censor_fill_parent motion_GA$num.r{$run}_censor.1D -infile roi_pc_Ventricles.r{$run}_vec.1D -write roi_pc_Ventricles_noc.rest
                1dcat roi_pc_Ventricles_noc.rest roi_pc_WM_subcud_noc.rest > roi_pc_Vent_WM.rest
                3dTproject -input pb04.GB$num.r$run.scale+tlrc -prefix $output_dir/errts.GB$num.rest+tlrc \
                -mask $rootdir/Connectivity/mask/full_mask_GAGB_n30+tlrc -ort $rootdir/bandpass_regs.1D

                cd $output_dir
                ## Calculating seed signals
                 3dmaskave -mask $caud_mask_dir/{GA$num}_1_caudate_head_resam_R+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_head_R.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_2_caudate_body_resam_R+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_body_R.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_3_caudate_tail_resam_R+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_tail_R.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_1_caudate_head_resam_L+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_head_L.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_2_caudate_body_resam_L+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_body_L.GA$num.rest.1D
                 3dmaskave -mask $caud_mask_dir/{GA$num}_3_caudate_tail_resam_L+tlrc -quiet errts.GA$num.rest+tlrc > errts.caudate_tail_L.GA$num.rest.1D
                 3dmaskave -mask $output_dir/cdh_L_GB-GA+tlrc -quiet errts.GB$num.rest+tlrc > errts.cdh_L_GB-GA.GB$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_L_GB-GA+tlrc -quiet errts.GB$num.rest+tlrc > errts.cdt_L_GB-GA.GB$num.rest.1D
                 3dmaskave -mask $output_dir/cdh_R_GB-GA+tlrc -quiet errts.GB$num.rest+tlrc > errts.cdh_R_GB-GA.GB$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_R_GB-GA+tlrc -quiet errts.GB$num.rest+tlrc > errts.cdt_R_GB-GA.GB$num.rest.1D
                 3dmaskave -mask $output_dir/cdh_L_GA+tlrc -quiet errts.GB$num.rest+tlrc > errts.cdh_L_GA.GB$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_L_GB+tlrc -quiet errts.GB$num.rest+tlrc > errts.cdt_L_GB.GB$num.rest.1D
                 3dmaskave -mask $output_dir/cdt_R_GB+tlrc -quiet errts.GB$num.rest+tlrc > errts.cdt_R_GB.GB$num.rest.1D
                      1dcat errts.caudate_head_R.GB$num.rest.1D \
                           errts.caudate_body_R.GB$num.rest.1D \
                           errts.caudate_tail_R.GB$num.rest.1D \
                           errts.caudate_head_L.GB$num.rest.1D \
                           errts.caudate_body_L.GB$num.rest.1D \
                           errts.caudate_tail_L.GB$num.rest.1D \
                           errts.cdh_L_GB-GA.GB$num.rest.1D \
                           errts.cdt_L_GB-GA.GB$num.rest.1D \
                           errts.cdh_R_GB-GA.GB$num.rest.1D \
                           errts.cdt_R_GB-GA.GB$num.rest.1D \
                           errts.cdh_L_GA.GB$num.rest.1D \
                           errts.cdt_L_GB.GB$num.rest.1D \
                           errts.cdt_R_GB.GB$num.rest.1D \
                           > errts.caudate.GB$num.rest.2D

end
