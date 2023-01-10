#!/bin/zsh

## ============================================================ ##
## default
res=2.683
fwhm=4
thresh_motion=0.4
list_run=('r01' 'r02' 'r03')

## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-s | --subject)
			## string
			subj="$2"
		;;
		-d | --day)
			## integer('1' or '2')
			dd="$2"
		;;
	esac
	shift ##takes one argument
done
day="day$dd"
## ============================================================ ##
dir_root="/mnt/ext5/GP/fmri_data"
dir_raw="$dir_root/raw_data/$subj/$day"
dir_preproc="$dir_root/preproc_data/$subj/$day"

dir_script="/home/sungbeenpark/Github/labs/GP/scripts"
## ============================================================ ##
if [ $day = 'day1' ]; then
	dir_output=$dir_preproc
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi

	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########
	
	cd $dir_output
	# ================================= skull-striping =================================
	3dSkullStrip							\
		-input "$dir_raw/MPRAGE.$subj.nii"	\
		-prefix $subj.anat.ss				\
		-orig_vol
	# ================================= unifize =================================
	3dUnifize						\
		-input $subj.anat.ss+orig	\
		-prefix $subj.anat.unifize	\
		-GM							\
		-clfrac 0.5
	# ================================== tlrc ==================================
	@auto_tlrc												\
		-base "/usr/local/afni/abin/MNI152_T1_2009c+tlrc"	\
		-input $subj.anat.unifize+orig						\
		-no_ss												\
		-init_xform AUTO_CENTER
	3dAFNItoNIFTI						\
		-prefix anat_final.$subj.nii	\
		$subj.anat.unifize+tlrc

	########
	# Func # : Despiking (3dDespike) -> Slice Timing Correction (3dTshift) -> Motion Correct EPI (3dvolreg)
	########  -> Alignment (@auto_tlrc) -> Spatial Blurring -> Nuisance Regression -> Scaling
	
	cd $dir_output
	touch out.pre_ss_warn.txt
	npol=4
	3dToutcount			\
		-automask		\
		-fraction		\
		-polort $npol	\
		-legendre		\
		"$dir_raw/func.$subj.localizer.nii" > outcount.$subj.localizer.1D
	if [ `1deval -a outcount.$subj.localizer.1D"{0}" -expr "step(a-0.4)"` ]; then
		echo "** TR #0 outliers: possible pre-steady state TRs" >> out.$subj.pre_ss_warn.txt
	fi
	#================================ despike =================================
	3dDespike									\
		-NEW									\
		-nomask									\
		-prefix pb00.$subj.localizer.despike	\
		"$dir_raw/func.$subj.localizer.nii"
	# ================================= tshift (pb01) =================================
	3dTshift								\
		-tzero 0							\
		-quintic							\
		-prefix pb01.$subj.localizer.tshift	\
		pb00.$subj.localizer.despike+orig
	# ================================= blip: B0-distortion correction =================================
	3dTcat						\
		-prefix blip_forward	\
		"$dir_raw/dist_AP.$subj.nii"
	3dTcat						\
		-prefix blip_reverse	\
		"$dir_raw/dist_PA.$subj.nii"
	
	3dTstat		\
		-median	\
		-prefix rm.blip.med.fwd blip_forward+orig
	3dTstat		\
		-median	\
		-prefix rm.blip.med.rev blip_reverse+orig
	
	3dAutomask									\
		-apply_prefix rm.blip.med.masked.fwd	\
		rm.blip.med.fwd+orig
	3dAutomask									\
		-apply_prefix rm.blip.med.masked.rev	\
		rm.blip.med.rev+orig
	
	3dQwarp -plusminus -pmNAMES Rev For		\
		-pblur 0.05 0.05 -blur -1 -1		\
		-noweight -minpatch 9				\
		-source rm.blip.med.masked.rev+orig	\
		-base rm.blip.med.masked.fwd+orig	\
		-prefix blip_warp
	
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig	\
		-source rm.blip.med.fwd+orig 						\
		-prefix blip_med_for
	
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig	\
		-source rm.blip.med.masked.fwd+orig					\
		-prefix blip_med_for_masked
	
	3dNwarpApply -quintic -nwarp blip_warp_Rev_WARP+orig	\
		-source rm.blip.med.masked.rev+orig					\
		-prefix blip_med_rev_masked
	
	3dNwarpApply -quintic -nwarp blip_warp_For_WARP+orig	\
		-source pb01.$subj.localizer.tshift+orig			\
		-prefix pb01.$subj.localizer.blip
	# ================================== Align Anatomy with EPI ==================================
	align_epi_anat.py												\
		-anat2epi -anat $subj.anat.unifize+orig -anat_has_skull no	\
	    -epi "$dir_raw/SBREF.$subj.localizer.nii" -epi_base 3		\
	    -epi_strip 3dAutomask										\
	    -suffix _al_junk -check_flip								\
	    -volreg off -tshift off -ginormous_move						\
	    -cost lpa -align_centers yes
	# ================================== register and warp (pb02) ========================
	3dvolreg -verbose -zpad 1 -cubic											\
		-base $dir_raw/SBREF.$subj.localizer.nii'[0]'							\
		-1Dfile dfile.$subj.localizer.1D -prefix rm.epi.volreg.$subj.localizer	\
		-1Dmatrix_save mat.localizer.vr.aff12.1D								\
		pb01.$subj.localizer.blip+orig
	
	3dcalc -overwrite -a pb01.$subj.localizer.blip+orig -expr 1 -prefix rm.$subj.epi.all1
	
	cat_matvec -ONELINE $subj.anat.unifize+tlrc::WARP_DATA	\
		-I $subj.anat.unifize_al_junk_mat.aff12.1D			\
		-I mat.localizer.vr.aff12.1D > mat.$subj.localizer.warp.aff12.1D
	
	3dAllineate -base $subj.anat.unifize+tlrc				\
		-input pb01.$subj.localizer.blip+orig				\
		-1Dmatrix_apply mat.$subj.localizer.warp.aff12.1D	\
		-mast_dxyz $res										\
		-prefix rm.epi.nomask.$subj.localizer
	
	3dAllineate -base $subj.anat.unifize+tlrc				\
		-input rm.$subj.epi.all1+orig						\
		-1Dmatrix_apply mat.$subj.localizer.warp.aff12.1D	\
		-final NN -quiet									\
		-mast_dxyz $res										\
		-prefix rm.epi.1.$subj.localizer
	
	3dTstat -min -prefix rm.epi.min.$subj.localizer rm.epi.1.$subj.localizer+tlrc
	
	3dcopy rm.epi.min.$subj.localizer+tlrc mask_epi_extents.$subj
	
	3dcalc -a rm.epi.nomask.$subj.localizer+tlrc -b mask_epi_extents.$subj+tlrc	\
		-expr 'a*b' -prefix pb02.$subj.localizer.volreg
	# =============================== blur (pb03) ====================================
	3dmerge -1blur_fwhm $fwhm -doall -prefix pb03.$subj.localizer.blur \
		pb02.$subj.localizer.volreg+tlrc
	# ================================= mask =========================================
	3dAutomask -dilate 1 -prefix full_mask.$subj pb03.$subj.localizer.blur+tlrc
	3dresample -master full_mask.$subj+tlrc -input $subj.anat.unifize+tlrc -prefix rm.resam.anat
	3dmask_tool -dilate_input 5 -5 -fill_holes -input rm.resam.anat+tlrc -prefix mask_anat.$subj
	# ================================= scale (pb04) ==================================
	3dTstat -prefix rm.mean_localizer pb03.$subj.localizer.blur+tlrc
	3dcalc -float													\
		-a pb03.$subj.localizer.blur+tlrc							\
		-b rm.mean_localizer+tlrc -c mask_epi_extents.$subj+tlrc	\
		-expr 'c * min(200, a/b*100)*step(a)*step(b)'				\
		-prefix pb04.$subj.localizer.scale
	# ================================ motion regressors =================================
	1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1	\
		-demean -write motion_demean.$subj.localizer.1D
	1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1	\
		-derivative -demean -write motion_deriv.$subj.localizer.1D
	1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1	\
		-show_censor_count -censor_prev_TR -censor_motion $thresh_motion motion_${subj}
	
	1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1	\
		-derivative -collapse_cols euclidean_norm				\
		-write motion_$subj.eucl_norm.1D
	
	1d_tool.py -infile dfile.$subj.localizer.1D -set_nruns 1	\
		-derivative -collapse_cols euclidean_norm				\
		-write motion_$subj.localizer.eucl_norm.1D

elif [ $day = 'day2' ]; then
	$dir_script/test.create_proc.zsh -s $subj -d 2
fi
