#!/bin/zsh

fan_dir=~/Desktop/Fan280
master=~/Desktop/Fan280/pb02.GA01.r01.volreg.nii.gz

output_dir=~/Desktop/fan280
if [ ! -d $output_dir ]; then
	mkdir -p -m 755 $output_dir
fi

foreach nn (`seq -f '%03g' 1 280`)
	3dresample -master $master -prefix $output_dir/fan.roi.GA.$nn.nii.gz -input $fan_dir/fan.roi.$nn.nii.gz
end
