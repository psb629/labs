#!/bin/tcsh

# ============================================================
## write down your path to save the data (approximately 15GB required)
set to_dir = /Volumes/T7SSD1/GA/fMRI_data/preproc_data
# ============================================================
## don't touch anything!
set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
set root_dir = /Volumes/clmnlab/GA
set from_dir = $root_dir/fmri_data/preproc_data
set betasLSS_dir = $root_dir/MVPA/LSS_pb02_MO_short_duration/data
set mask_dir = $root_dir/fmri_data/masks
# ============================================================

foreach id (GA GB)
	foreach nn ($subj_list)
		set subj = ${id}${nn}
		echo "Processing $subj..."
		if ( ! -d $to_dir/$nn ) then
			mkdir -p -m 755 $to_dir/$nn
		endif
		## anat_final
		set from = $from_dir/$subj/anat_final.$subj+tlrc.
		set to = $to_dir/$nn/anat_final.$subj.nii.gz
		3dAFNItoNIFTI -prefix $to $from
		rm $to_dir/$nn/anat_final.$subj+tlrc.*
		## motion.1D
		foreach run (`count -digits 2 0 7`)
			set from = $from_dir/$subj/motion_demean.$subj.r$run.1D
			set to = $to_dir/$nn/motion_demean.$subj.r$run.1D
			cp $from $to
			set from = $from_dir/$subj/motion_$subj.r${run}_censor.1D
			set to = $to_dir/$nn/motion_censor.$subj.r$run.1D
			cp $from $to
		end
		## betasLSS
		foreach run (`count -digits 2 1 6`)
			set from = $betasLSS_dir/betasLSS.MO.shortdur.$subj.r$run+tlrc
			set to = $to_dir/$nn/betasLSS.$subj.r$run.nii.gz
			if ( ! -e $from.HEAD ) then
				echo " $from doesn't exist!"
			else
				3dAFNItoNIFTI -prefix $to $from
			endif
		end
		## compressing
		gzip -1v $to_dir/$nn/*.BRIK
	end
end
# ============================================================

