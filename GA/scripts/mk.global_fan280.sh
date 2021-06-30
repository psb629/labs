#!/bin/zsh

fan_dir=~/Desktop/Fan280_GA
output_dir=$fan_dir

list=()
foreach nn (`seq -f "%03g" 1 280`)
	list=($list $fan_dir/fan.roi.GA.$nn.nii.gz)
end

pname=$output_dir/fan.roi.GA.all.nii.gz
3dmerge -gmax -prefix $pname $list

3dBrickStat -count -non-zero $pname
