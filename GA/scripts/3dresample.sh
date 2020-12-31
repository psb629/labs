#!/bin/tcsh

set root_dir = /Volumes/T7SSD1/GA
set fmri_dir = $root_dir/fMRI_data
set roi_dir = $fmri_dir/roi
set fan_dir = $roi_dir/fan280

set master = $roi_dir/full_mask.GAs.nii.gz
foreach nn (`count -digit 3 1 280`)
	## check an existance of a fan mask
	set from = $fan_dir/fan.roi.resam.$nn.nii.gz
	if (! -e $from) then
		echo "$from doesn't exist"
		continue
	endif
	## resampling
	set temp = $fan_dir/temp.$nn.nii.gz
	3dresample -master $master -prefix $temp  -input $from
	set to = $fan_dir/fan.roi.GA.$nn.nii.gz
	3dcalc -a $temp -expr 'ispositive(a)' -prefix $to
	rm $temp $from
end
