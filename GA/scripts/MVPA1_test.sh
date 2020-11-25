#!/bin/tcsh

###########################################################################################
set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
set reg_num = Reg3
set stat_dir = {$reg_num}_MVPA1_test
###########################################################################################
set root_dir = /Volumnes

foreach subj ($subj_list)
	set preproc_subj_dir = $root_dir/fMRI_data/preproc_data/$subj/preprocessed
	if (! -d $preproc_subj_dir) then
		continue
	endif
	set reg_subj_dir = $root_dir/behav_data/regressors/$subj
	if (! -d $reg_subj_dir) then
		continue
	endif
	set stat_subj_dir = $root_dir/fMRI_data/stats/$stat_dir/$subj
	if (! -d $stat_subj_dir) then
		mkdir -p -m 777 $stat_subj_dir
	endif

	foreach run (r01 r02 r03)
		3dLSS -input $preproc_subj_dir/pb04.$subj.$run.scale+tlrc.HEAD	\
			-mask $preproc_subj_dir/full_mask.$subj+tlrc.HEAD			\
			-matrix $root_dir/fMRI_data/stats/Reg10_{*}/$subj/$run.X.xmat.1D		\
			-save1D $stat_subj_dir/$run.X.LSS.1D		\
			-prefix $stat_subj_dir/$run.LSSout
		3dAFNItoNIFTI -prefix $stat_subj_dir/$run.LSSout.nii.gz $stat_subj_dir/$run.LSSout+tlrc
	end
	echo "subject $subj completed"
end
