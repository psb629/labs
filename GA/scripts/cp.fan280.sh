#!/bin/tcsh

set data_dir = /Volumes/clmnlab/GA/fmri_data/masks/Fan/Fan280
set to_dir = /Volumes/T7SSD1/Fan280
if (! -d $to_dir) then
	mkdir -p -m 755 $to_dir
endif

foreach nn (`count -digits 3 1 280`)
	set from = $data_dir/fan.roi.$nn.nii.gz
	if (! -e $from) then
		echo " $from doesn't exist!"
		continue
	endif
	cp $from $to_dir
end
