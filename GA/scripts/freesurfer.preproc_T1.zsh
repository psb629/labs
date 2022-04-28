#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )

dir_root=/mnt/ext5/NAS05/GA/fmri_data/freesurfer

foreach gg ('GA' 'GB')
	foreach nn ($nn_list)
		subj=$gg$nn
		dir_output=$dir_root
		if [ ! -d $dir_output ]; then
			mkdir -p -m 755 $dir_output
		fi
		t1=/mnt/sda2/GA/fmri_data/preproc_data/$nn/$subj.MPRAGE.nii
		cp -n $t1 $dir_output
	end
end
## T1s would be reconstructed by FreeSurfer
cd $dir_output
SUBJECTS_DIR=`pwd`
ls *.nii | parallel --jobs 60 recon-all -s {.} -i {} -all -qcache
## remove previous data
rm $dir_output/*.nii
