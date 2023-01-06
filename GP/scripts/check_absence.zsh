#!/bin/zsh

dir_root="/mnt/ext5/GP/fmri_data/raw_data"

list_subj=(`ls $dir_root | grep GP`)

foreach subj ($list_subj)
	echo "# ============= $subj ==============#"
	foreach day ('day1' 'day2')
		if [ ! -d $dir_root/$subj/$day ]; then
			print ' x'
			continue
		fi
		cd $dir_root/$subj/$day
		ls -al | grep ^d | wc -l
	end
end
