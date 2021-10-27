#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================
dir_root=/home/sungbeenpark
dir_fmri=$dir_root/GoogleDrive/GA/fMRI_data
dir_roi=$dir_fmri/roi
dir_stats=$dir_fmri/stats/GLM.MO
# ============================================================
 #region='full_mask'
 #mask=full_mask.GAs.nii.gz
region='fan_all'
mask=fan.roi.GA.all.nii.gz
# ============================================================
dir_fin=$dir_root/GLM.MO/tsmean/$region
if [ ! -d $dir_fin ]; then
	mkdir -p -m 755 $dir_fin
fi
# ============================================================
foreach nn ($list_nn)
	dir_data=$dir_stats/$nn
	foreach gg ('GA' 'GB')
		subj=$gg$nn
		echo "$subj"
		foreach run (r01 r02 r03 r04 r05 r06)
			echo "$run..."
			data=$subj.bp_demean.errts.MO.$run.nii.gz
			fname=tsmean.bp_demean.errts.MO.$subj.$run.$region.1D
			
			3dmaskave -quiet -mask $dir_roi/fan280/$mask $dir_data/$data >$dir_fin/$fname
		end
	end
end
# ============================================================
 #find $dir_work -type f -size 0 -delete
