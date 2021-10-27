#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
list_run=(`seq -f "r%02g" 1 6`)
# ============================================================
dir_proc=/Volumes/clmnlab/GA/fmri_data/preproc_data
dir_output=/Volumes/WD_HDD1/GA/fmri_data/pb04.errts_tproject
# ============================================================
## check files
 #foreach gg in 'GA' 'GB'
 #	foreach nn in $list_nn
 #		subj=$gg$nn
 #		dir_data=$dir_proc/$subj
 #		foreach run in $list_run
 #			pb04=pb04.$subj.$run.scale+tlrc
 #			if [ ! -e $dir_data/$pb04.HEAD ]; then
 #				echo "$pb04 doesn't exist!"
 #			fi
 #			demean=motion_demean.$subj.$run.1D
 #			if [ ! -e $dir_data/$demean ]; then
 #				echo "$demean doesn't exist!"
 #			fi
 #			censor=motion_$subj.${run}_censor.1D
 #			if [ ! -e $dir_data/$censor ]; then
 #				echo "$censor doesn't exist!"
 #			fi
 #			mask=full_mask.$subj+tlrc
 #			if [ ! -e $dir_data/$mask.HEAD ]; then
 #				echo "$mask doesn't exist!"
 #			fi
 #		end
 #	end
 #end
# ============================================================
foreach gg in 'GA' 'GB'
	foreach nn in $list_nn
		subj=$gg$nn
		dir_data=$dir_proc/$subj
		dir_fin=$dir_output/$nn
		if [ ! -d $dir_fin ]; then
			mkdir -p -m 755 $dir_fin
		fi
		foreach run in $list_run
			pb04=pb04.$subj.$run.scale+tlrc
			demean=motion_demean.$subj.$run.1D
			censor=motion_$subj.${run}_censor.1D
			mask=full_mask.$subj+tlrc

			3dTproject -polort 0 -input $dir_data/$pb04 \
				-mask $dir_data/$mask \
				-passband 0.01 0.1 \
				-censor $dir_data/$censor -cenmode ZERO \
				-ort $dir_data/$demean \
				-prefix $dir_fin/errts.tproject.$subj.$run.nii
		end
	end
end
