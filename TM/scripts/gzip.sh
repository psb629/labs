#!/bin/tcsh

set subj_list = (TML09_PILOT TML10_PILOT TML11_PILOT \
			TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20 \
			TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29)
set subj_list = (KJW)

####################### auto procedure #######################

set TM_dir = /clmnlab/TM
set fMRI_dir = $TM_dir/fMRI_data
set behav_dir = $TM_dir/behav_data
set preproc_dir = $fMRI_dir/preproc_data

foreach subj ($subj_list)
	set subj_preproc_dir = $preproc_dir/$subj
	cd $subj_preproc_dir
	gzip -1v *.BRIK

	cd ./preprocessed
	gzip -1v *.BRIK

	echo "$subj Done!"
end
