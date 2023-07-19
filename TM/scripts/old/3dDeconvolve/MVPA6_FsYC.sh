#!/bin/tcsh

###########################################################################################
set subj_list = (\
				TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT TML10_PILOT TML11_PILOT\
				TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20\
				TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29\
				)
set reg_num = Reg11
set stat_dir = {$reg_num}_MVPA6_FsYC	# freq_1 / freq_2 / Yellow cross / Coin
###########################################################################################

set TM_dir = /clmnlab/TM

foreach subj ($subj_list)
	set preproc_subj_dir = $TM_dir/fMRI_data/preproc_data/$subj/preprocessed
	if (! -d $preproc_subj_dir) then
		continue
	endif
	set reg_subj_dir = $TM_dir/behav_data/regressors/$subj
	if (! -d $reg_subj_dir) then
		continue
	endif
	set stat_subj_dir = $TM_dir/fMRI_data/stats/$stat_dir/$subj
	if (! -d $stat_subj_dir) then
		mkdir -p -m 777 $stat_subj_dir
	endif

	foreach run (r01 r02 r03)
		3dLSS -input $preproc_subj_dir/pb04.$subj.$run.scale+tlrc.HEAD	\
			-mask $preproc_subj_dir/full_mask.$subj+tlrc.HEAD			\
			-matrix $TM_dir/fMRI_data/stats/Reg10_{*}/$subj/$run.X.xmat.1D		\
			-save1D $stat_subj_dir/$run.X.LSS.1D		\
			-prefix $stat_subj_dir/$run.LSSout
		3dAFNItoNIFTI -prefix $stat_subj_dir/$run.LSSout.nii.gz $stat_subj_dir/$run.LSSout+tlrc
	end
	echo "subject $subj completed"
end
