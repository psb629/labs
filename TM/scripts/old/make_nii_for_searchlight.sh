#!/bin/tcsh

######################## input #######################
#set subj_list = (\
#				TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML10_PILOT TML11_PILOT\
#				TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20\
#				TML21 TML22 TML23 TML24 TML25 TML26\
#				)
set subj_list = (TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT)

####################### auto procedure #######################

set TM_dir = /clmnlab/TM
set fMRI_dir = $TM_dir/fMRI_data
set behav_dir = $TM_dir/behav_data
set preproc_dir = $fMRI_dir/preproc_data
set stats_dir_5 = $fMRI_dir/stats/Reg5_{*}
set stats_dir_6 = $fMRI_dir/stats/Reg6_{*}
set stats_dir_7 = $fMRI_dir/stats/Reg7_MVPA3_IM_COY
set stats_dir_8 = $fMRI_dir/stats/Reg8_GLM_vibration_vs_yellow
set run_list = `count -digit 2 1 3`

foreach subj ($subj_list)
	echo $subj
	set subj_behav_dir = $behav_dir/$subj
	set subj_preproc_dir = $preproc_dir/$subj/preprocessed

 #	# full mask is converted to .nii.gz #
 #	set subj_fullmask = $subj_preproc_dir/full_mask.{$subj}+tlrc
 #	set pref = $subj_preproc_dir/full_mask.{$subj}.nii.gz
 #	if (! -e $pref) then
 #		3dAFNItoNIFTI -prefix $pref $subj_fullmask
 #	endif
 #
 #	cd $stats_dir_8/$subj
 #	3dcalc -a Clust_mask+tlrc -expr 'ispositive(a)' -prefix Clust_mask_binary
 #	# cluster mask of the center freq. is converted to .nii.gz #
 #	set subj_clustmask = $stats_dir_8/$subj/Clust_mask_binary+tlrc
 #	set pref = $stats_dir_8/$subj/Clust_mask_binary.{$subj}.nii.gz
 #	if (! -e $pref) then
 #		3dAFNItoNIFTI -prefix $pref $subj_clustmask
 #	endif

	# LSS dataset is converted to .nii.gz #
	set subj_stats_dir = $stats_dir_5/$subj
	foreach run ($run_list)
		set subj_LSSout = $subj_stats_dir/r{$run}.LSSout+tlrc
		set pref = $subj_stats_dir/r{$run}.LSSout.nii.gz
		if (! -e $pref) then
			3dAFNItoNIFTI -prefix $pref $subj_LSSout
		endif
	end

 #	# LSS dataset is converted to .nii.gz #
 #	set subj_stats_dir = $stats_dir_6/$subj
 #	foreach run ($run_list)
 #		set subj_LSSout = $subj_stats_dir/r{$run}.LSSout+tlrc
 #		set pref = $subj_stats_dir/r{$run}.LSSout.nii.gz
 #		if (! -e $pref) then
 #			3dAFNItoNIFTI -prefix $pref $subj_LSSout
 #		endif
 #	end
 #	# LSS dataset is converted to .nii.gz #
 #	set subj_stats_dir = $stats_dir_7/$subj
 #	foreach run ($run_list)
 #		set subj_LSSout = $subj_stats_dir/r{$run}.LSSout+tlrc
 #		set pref = $subj_stats_dir/r{$run}.LSSout.nii.gz
 #		if (! -e $pref) then
 #			3dAFNItoNIFTI -prefix $pref $subj_LSSout
 #		endif
 #	end

end
