#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================
dir_data=/home/sungbeenpark/GoogleDrive/GA
dir_behav=$dir_data/behav_data
dir_fmri=$dir_data/fMRI_data
dir_roi=$dir_fmri/roi
dir_stats=$dir_fmri/stats
# ============================================================
region='full_mask'
mask=full_mask.GAs.nii.gz
# ============================================================
dir_fin=$dir_stats/GLM.MO/tsmean/$region
if [ ! -d $dir_fin ]; then
	mkdir -p -m 755 $dir_fin
fi
# ============================================================
dir_work=~/tsmean
if [ ! -d $dir_work ]; then
	mkdir -p -m 755 $dir_work
fi
cp -n $dir_roi/$mask $dir_work
# ============================================================
foreach nn ($list_nn)
	foreach gg (GA GB)
		subj=$gg$nn
		foreach run (r01 r02 r03 r04 r05 r06)
			data=$subj.bp_demean.errts.MO.$run.nii.gz
			fname=tsmean.bp_demean.errts.MO.$subj.$run.$region.1D
			
			## 만약 최종 output 이 없으면, 계산을 위한 데이터 복사부터 시작
			if [ ! -e $dir_fin/$fname ]; then
				if [ ! -e $dir_work/$data ]; then
					echo "copying $data to $dir_work"
					cp -n $dir_stats/GLM.MO/$nn/$data $dir_work
				fi
				echo "Calculating ${gg}${nn} $run $regions[$aa] ..."
	 			dir_output=$dir_work/$region
				if [ ! -d $dir_output ]; then
					mkdir -p -m 755 $dir_output
				fi
				3dmaskave -quiet -mask $dir_work/$mask $dir_work/$data >$dir_output/$fname
			fi
		end
		if [ -e $dir_work/$data ]; then
			rm $dir_work/$data
		fi
	end
end
# ============================================================
rm $dir_work/$mask
# ============================================================
cp -n -r $dir_work/$region/* $dir_fin
find $dir_fin -type f -size 0
