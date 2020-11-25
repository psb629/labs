#!/bin/tcsh

set root_dir = /Volumes/T7SSD1/GL
set roi_dir = $root_dir/roi
set output_dir = $roi_dir

# ========================= combine fan masks ========================= #
set mask_list = (M1 S1)
#set M1 = (055 057 059)
#set M1 = (057)	# sskim
set M1 = (055) # most suitable area
#set S1 = (155 159 161)
#set S1 = (155) # sskim
set S1 = (159) # most suitable area

set fan_dir = $root_dir/roi/fan280
set lower_case = (a b c d e f g h i j k l m n o p q r s t u v w x y z)
foreach roi ($mask_list)
	switch($roi)
	case 'M1':
		set temp = ($M1)
		breaksw
	case 'S1':
		set temp = ($S1)
		breaksw
	default:
		breaksw
	endsw
	set aa = ()
	set bb = (0)
	foreach i (`count 1 $#temp`)
		set aa = ($aa `echo "-$lower_case[$i] $fan_dir/fan.roi.resam.$temp[$i].nii.gz"`)
		set bb = ($bb+$lower_case[$i])
	end
	set pname = $output_dir/mask.$roi
	3dcalc `echo "$aa -expr ispositive($bb) -prefix $pname"`
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*
	echo " # of voxels in $pname.nii.gz = `3dBrickStat -count -positive $pname.nii.gz`"
end
# ========================= intersection of the above masks and statmove roi ========================= #
set roi_cluster = $roi_dir/clust.statmove_group.NN=3.p=1e-5.nii.gz
set output_dir = $roi_dir

foreach roi ($mask_list)
	set pname = $output_dir/inter.${roi}
	3dcalc -a $roi_cluster -b $roi_dir/mask.$roi.nii.gz -expr 'a*b' -prefix $pname
	3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc
	rm $pname+tlrc.*
end
