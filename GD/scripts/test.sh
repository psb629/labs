#!/bin/tcsh

set subj = GD01
echo $subj | sed "s/D/A/g"
# ========================= make the group full-mask =========================
#set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)
##set subj_list = (GD11 GD07 GD30 GD02 GD32 GD23 GD01 GD33 GD20 GD44 GD26 GD15)
#set n_subj = `echo "$#subj_list"`
#set fMRI_dir = /Volumes/T7SSD1/GD/fMRI_data
#set preproc_dir = $fMRI_dir/preproc_data
#set output_dir = $fMRI_dir/masks/full
#
#set temp = ()
#foreach subj ($subj_list)
#	set temp = ($temp $preproc_dir/$subj/preprocessed/full_mask.$subj+tlrc.HEAD)
#end
#set gmask = full_mask.GDs_n$n_subj
#3dMean -mask_inter -prefix $output_dir/$gmask $temp
#
#if ( -e $output_dir/$gmask.nii.gz ) then
#	rm $output_dir/$gmask.nii.gz
#endif
#3dAFNItoNIFTI -prefix $output_dir/$gmask.nii.gz $output_dir/$gmask+tlrc.
#
#rm $output_dir/$gmask+tlrc.*
# ============================================================================
set roi = (caudate_head_R caudate_body_R caudate_tail_R caudate_head_L caudate_body_L caudate_tail_L)
foreach i (0 1 2 3 4 5 6)
	echo "$roi[$i]"
end
foreach i (`count -digit 1 1 $#roi`)
	@ i = $i - 1
	echo $i
end
echo "len(roi)=${#roi}"
