#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )

dir_tmp=~/tttemp
if [ ! -d $dir_tmp ]; then
	mkdir -p -m 755 $dir_tmp
fi

foreach nn in $list_nn
	dir_from=~/GoogleDrive/GA/fMRI_data/preproc_data/$nn
	foreach gg in 'GA' 'GB'
		dir_to=/mnt/sda2/GA/fmri_data/preproc_data/$gg$nn
		cp -n $dir_from/motion*.$gg$nn.*.1D $dir_tmp
		sudo cp -n $dir_tmp/* $dir_to
		rm $dir_tmp/*
	end
end
