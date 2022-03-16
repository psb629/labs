#!/bin/zsh

dir_fan=/mnt/sda2/GA/fmri_data/masks/fan280
dir_output=$dir_fan

list=()
foreach nn (`seq -f "%03g" 1 280`)
	list=($list $dir_fan/fan.roi.GA.$nn.nii.gz)
end

pname=$dir_output/fan.roi.GA.all.nii
3dmerge -gmax -prefix $pname $list

3dBrickStat -count -non-zero $pname
