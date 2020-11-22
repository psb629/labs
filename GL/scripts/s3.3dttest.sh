#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
#set subj = GL${subj_list[1]}

set root_dir = /Volumes/T7SSD1/GL
set roi_dir = $root_dir/roi
set ppi_dir = $root_dir/ppi
set reg_psych_dir = $ppi_dir/reg
set group_dir = $ppi_dir/group
set output_dir = $group_dir

# runs
set runs = `count -digits 2 1 4`
# seed label
set roi_list = (M1 S1)
# two conditions
set cond_list = (FB nFB)
# sub-brick of interesting
set nn = 17 # ppiFB_ppinFB_GLT#0_Coef

# ========================= make the group directory =========================
if ( ! -d $group_dir ) then
	echo "make the group directory at $ppi_dir"
	mkdir -m 755 $group_dir
endif
# ========================= group full-mask =========================
set gmask = $roi_dir/full/full_mask.group.nii.gz
# ========================= 3dttest++ =========================
foreach sd ($roi_list)
	set setA = ()
	foreach ss ($subj_list)
		set subj = GL$ss
		set pname = $output_dir/temp.$subj.$sd
		3dcalc -a "$ppi_dir/PPIstat.$subj.$sd+tlrc[$nn]" -expr 'a' -prefix $pname
		set setA = ($setA $pname+tlrc)
	end
	set pname = $output_dir/PPIstat.$nn.group.$sd
	3dttest++ -mask $gmask -prefix $pname -setA $setA
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*\
		$output_dir/temp.GL??.*
end
