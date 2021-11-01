#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
list_run=(`seq -f "r%02g" 1 6`)
# ============================================================
dir_data=/mnt/sda2/GA/fmri_data/pb04.errts_tproject

dir_root=/home/sungbeenpark
dir_roi=$dir_root/GoogleDrive/GA/fMRI_data/roi
dir_output=$dir_root/GA/pb04.errts_tproject/tsmean
# ============================================================
region='fan_all'
mask=$dir_roi/fan280/fan.roi.GA.all.nii.gz
# ============================================================
foreach nn in $list_nn
	foreach gg in 'GA' 'GB'
		subj=$gg$nn
		foreach run in $list_run
			datum=errts.tproject.$subj.$run.nii
			if [ ! -e $dir_data/$nn/$datum ]; then
				echo "$datum does not exist!"
				continue
			fi

			dir_fin=$dir_output/$region
			if [ ! -d $dir_fin ]; then
				mkdir -p -m 755 $dir_fin
			fi

			fin=tsmean.errts_tproject_bp.$subj.$run.$region.1D
			if [ ! -e $dir_fin/$fin ]; then
				echo "Calculating $subj $run $region ..."
				3dmaskave -quiet -mask $mask $dir_data/$nn/$datum >$dir_fin/$fin
			fi
		end
	end
end
