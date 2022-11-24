#!/bin/zsh

dir_root="/mnt/ext5/SMC/fmri_data/raw_data"

dir="pre"
for dir in "pre" "post"
{
	list_dname=(`find $dir_root/$dir -maxdepth 1 -type d -name "S*" | sed "s;$dir_root/$dir/;;g" | sort -n`)
	list_subj=()
	for dname in $list_dname
		list_subj=($list_subj "$dname[1,3]")
	print "$dir : $list_subj ($#list_subj)"
}
