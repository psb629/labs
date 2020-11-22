#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

set root_dir = /Volumes/T7SSD1/GL
set stats_dir = $root_dir/fMRI_data/stats/Reg1_{*}
set roi_dir = $root_dir/roi
set group_dir = $ppi_dir/group
set output_dir = $group_dir

# sub-brick of interesting
set nn = 7 # diff_GLT#0_Coef
# ========================= make the group directory =========================
if ( ! -d $group_dir ) then
	echo "make the group directory at $stats_dir"
	mkdir -m 755 $group_dir
endif
# ========================= group full-mask =========================
set gmask = $roi_dir/full/full_mask.group.nii.gz
# ========================= 3dttest++ =========================
	set setA = ()
	foreach ss ($subj_list)
		set subj = GL$ss
		set pname = $output_dir/temp.$subj
		3dcalc -a "$stats_dir/$subj/stat.$subj.nii.gz[$nn]" -expr 'a' -prefix $pname
		set setA = ($setA $pname+tlrc)
	end
	set pname = $output_dir/stat.$nn.group
	3dttest++ -mask $gmask -prefix $pname -setA $setA
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*\
		$output_dir/temp.GL??.*
