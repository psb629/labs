#!/bin/tcsh

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
set nsubj = $#subj_list

set root_dir = /Volumes/T7SSD1/GL
set fmri_dir = $root_dir/fMRI_data
set preproc_dir = $fmri_dir/preproc_data
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
# set nn = 17 # ppiFB_ppinFB_GLT#0_Coef

# ========================= make the group directory =========================
if ( ! -d $group_dir ) then
	echo "make the group directory at $ppi_dir"
	mkdir -m 755 $group_dir
endif
# ========================= copy an anat_final.GL04 to the group directory =========================
set from = $preproc_dir/GL04/anat_final.GL04.nii.gz
set to = $group_dir/anat_final.GL04.nii.gz
if ( ! -e $to ) then
	cp $from $to
endif
# ========================= group full-mask =========================
set gmask = $roi_dir/full/full_mask.group.n$nsubj.nii.gz
# ========================= 3dttest++ =========================
foreach sd ($roi_list)
	# ========================= setA =========================
	# sub-brick of interesting
	set nn = 11 # ppi_FB#0_Coef

	set setA = ()
	foreach ss ($subj_list)
		set subj = GL$ss
		set pname = $output_dir/tempA.$subj.$sd
		3dcalc -a "$ppi_dir/PPIstat.$subj.$sd+tlrc[$nn]" -expr 'a' -prefix $pname
		set setA = ($setA $pname+tlrc)
	end
	# ========================= setB =========================
	# sub-brick of interesting
	set nn = 14 # ppi_nFB#0_Coef

	set setB = ()
	foreach ss ($subj_list)
		set subj = GL$ss
		set pname = $output_dir/tempB.$subj.$sd
		3dcalc -a "$ppi_dir/PPIstat.$subj.$sd+tlrc[$nn]" -expr 'a' -prefix $pname
		set setB = ($setB $pname+tlrc)
	end
	# ========================= 3dttest++ =========================
	set pname = $output_dir/PPIstat.group.n$nsubj.$sd
	3dttest++ -mask $gmask -setA $setA -setB $setB -prefix $pname -paired -Clustsim
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*\
		$output_dir/temp?.GL??.*
end
