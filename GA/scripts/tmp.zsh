#!/bin/zsh
#
list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
list_run=(`seq -f "r%02g" 1 6`)
# ============================================================
dir_root=/Volumes/clmnlab/GA
dir_data=$dir_root/Connectivity/data/bp04_run1to3
# ============================================================
foreach nn in $list_nn
	foreach gg in 'GA' 'GB'
		foreach run in $list_run
			datum=bp04.$gg$nn.$run.scale.nii.gz
			if [ ! -e $dir_data/$datum ]; then
				echo $datum
			fi
		end
	end
end
3dTproject -input /clmnlab/GA/fmri_data/preproc_data/GA01/pb04.GA01.r01.scale+tlrc \
			-prefix /clmnlab/GA/Connectivity/data/bp04_run1to3/bp04.GA01.r01.scale+tlrc \
			-polort 4 \
			-mask /clmnlab/GA/Connectivity/mask/full_mask.GAGB25+tlrc \
			-passband 0.01 0.1
