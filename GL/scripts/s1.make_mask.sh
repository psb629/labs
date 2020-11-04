#!/bin/tcsh

set root_dir = /Volumes/T7SSD1/GL
set output_dir = $root_dir/roi

set mask_list = (M1 S1)
#set M1 = (055 057 059)
set M1 = (057)
#set S1 = (155 159 161)
set S1 = (155)

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
end
