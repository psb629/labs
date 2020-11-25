#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

set root_dir = /Volumes/T7SSD1/GL
set fmri_dir = $root_dir/fMRI_data
set preproc_dir = $fmri_dir/preproc_data
set stats_dir = $fmri_dir/stats/Reg1_{*}
set roi_dir = $root_dir/roi
set group_dir = $stats_dir/group
set output_dir = $group_dir

# ========================= make the group directory =========================
if ( ! -d $group_dir ) then
	echo "make the group directory at $stats_dir"
	mkdir -m 755 $group_dir
endif
# ========================= group full-mask =========================
set gmask = $roi_dir/full/full_mask.group.nii.gz
# ========================= copy anat_final.GL04.nii.gz to group_dir =========================
set from = $preproc_dir/GL04/anat_final.GL04.nii.gz
set to = $output_dir/anat_final.GL04.nii.gz
if ( ! -e $to ) then
	cp $from $to
endif
# ========================= setA =========================
# sub-brick of interesting
set nn = 1 # FB#0_Coef

set setA = ()
foreach ss ($subj_list)
	set subj = GL$ss
	cp $stats_dir/$subj/stats.$subj.nii.gz $output_dir
	set pname = $output_dir/tempA.$subj
	3dcalc -a "$stats_dir/$subj/stats.$subj.nii.gz[$nn]" -expr 'a' -prefix $pname
	set setA = ($setA $pname+tlrc)
end
# ========================= setB =========================
# sub-brick of interesting
set nn = 4 # nFB#0_Coef

set setB = ()
foreach ss ($subj_list)
	set subj = GL$ss
	cp $stats_dir/$subj/stats.$subj.nii.gz $output_dir
	set pname = $output_dir/tempB.$subj
	3dcalc -a "$stats_dir/$subj/stats.$subj.nii.gz[$nn]" -expr 'a' -prefix $pname
	set setB = ($setB $pname+tlrc)
end
# ========================= 3dttest++ =========================
set pname = $output_dir/stats.group
3dttest++ -mask $gmask -setA $setA -setB $setB -prefix $pname -paired
3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
rm $pname+tlrc.*\
	$output_dir/temp?.GL??+tlrc.*
