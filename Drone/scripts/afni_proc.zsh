#!/bin/zsh

list_run=(`seq -f "r%02g" 1 4`)

dir_root="/mnt/ext1/Drone"
dir_fmri="$dir_root/fmri_data"

dir_script=/home/sungbeenpark/Github/labs/GL/scripts
# ==================================================
subj="DRN02"
dir_raw="$dir_fmri/raw_data/$subj"
dir_output="$dir_fmri/preproc_data/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ==================================================================
afni_proc.py -subj_id $subj -script $dir_script/preproc_$suj.tcsh \
			-out_dir $dir_output \
			-dsets \
				$dir_raw/func.$subj.r01+orig.HEAD \
				$dir_raw/func.$subj.r02+orig.HEAD \
				$dir_raw/func.$subj.r03+orig.HEAD \
				$dir_raw/func.$subj.r04+orig.HEAD \
			-blocks 					'despike' 'tshift' 'align' 'tlrc' 'volreg' 'blur' 'mask' 'scale' 'regress'	\
			-radial_correlate_blocks	'tcat' 'volreg'																\
			-copy_anat					$dir_raw/$subj.MPRAGE+orig													\
			-anat_has_skull				'yes'																		\
			-anat_uniform_method		'unifize'																	\
			-anat_unif_GM 'yes'\
			-tcat_remove_first_trs 2 \
			-tshift_opts_ts \
			-tpattern 'alt+z2' \
			-tlrc_base MNI152_T1_2009c+tlrc \
			-tlrc_opts_at \
			-init_xform AUTO_CENTER \
			-align_opts_aea \
			-cost 'lpc+ZZ' -giant_move -check_flip\
			-volreg_align_e2a \
			-volreg_align_to MIN_OUTLIER \
			-volreg_tlrc_warp \
			-blur_size 4.0 \
			-regress_stim_times $dir_reg/${subj}_RewFB.txt $dir_reg/${subj}_RewnFB.txt \
			-regress_stim_labels 'RewFB' 'RewnFB' \
			-regress_stim_types 'AM2' -regress_basis 'BLOCK(1,1)' \
			-regress_opts_3dD \
			-jobs 1 \
			-gltsym 'SYM: RewFB -RewnFB' -glt_label 1 'RewFB-RewnFB' \
			-regress_censor_motion 0.4 \
			-regress_censor_outliers 0.05 \
			-regress_bandpass 0.01 0.1 \
			-regress_motion_per_run \
			-regress_apply_mot_types 'demean' 'deriv' \
			-html_review_style pythonic
 #			-execute
