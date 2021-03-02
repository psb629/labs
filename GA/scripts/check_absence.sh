#!/bin/tcsh

set fan_dir = /Volumes/T7SSD1/GA/fMRI_data/roi/fan280

foreach i (`count -digit 3 1 280`)
	set temp = $fan_dir/fan.roi.GA.$i.nii.gz
	if ( ! -e $temp) then
		echo "$temp doesn't exist"
	endif
end
