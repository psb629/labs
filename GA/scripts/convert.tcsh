#!/bin/tcsh

set list_nn = ( 01 02 05 07 08 \
				11 12 13 14 15 \
				18 19 20 21 23 \
				26 27 28 29 30 \
				31 32 33 34 35 \
				36 37 38 42 44 )
set list_run = (`seq -f "r%02g" 1 6`)

 #set dir_root = $HOME/GA
set dir_root = /mnt/sda2/GA
# ==================================================
foreach nn ($list_nn)
	foreach gg ('GA' 'GB')
		set subj = $gg$nn
		
		set dir_raw = /mnt/sda2/GA/fmri_data/raw_data/$gg$nn/
		set dir_output = $dir_root/fmri_data/preproc_data/$nn
		if ( ! -d $dir_output ) then
			mkdir -p -m 755 $dir_output
		endif
		## ==================================================================
		## Convert *.IMA files to *.nii
		### B0 distortion
		foreach B0 ('dist_PA' 'dist_AP')
			set dir = $dir_raw/$B0
			if ( -d $dir ) then
				set fin = $dir_output/$subj.$B0.nii
				if ( -f $fin ) then
					continue
				endif
				cd $dir_output
				Dimon -infile_pat "$dir/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
					-gert_outdir $dir_output -gert_quit_on_err
				3dWarp -deoblique -prefix $fin $dir_output/temp+orig
				rm $dir_output/temp* $dir_output/GERT_Reco_dicom* $dir_output/dimon*
			endif
		end
		### main task
		foreach run ($list_run)
			#### EPI
			set fin = $dir_output/$subj.func.$run.nii
			if ( ! -f $fin ) then
				cd $dir_output
				Dimon -infile_pat "$dir_raw/$run/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
					-gert_outdir $dir_output -gert_quit_on_err
				3dWarp -deoblique -prefix $fin $dir_output/temp+orig
				rm $dir_output/temp* $dir_output/GERT_Reco_dicom* $dir_output/dimon*
			endif
			#### Single-Band REFerence
			set fin = $dir_output/$subj.SBREF.$run.nii
			if ( ! -f $fin ) then
				cd $dir_output
				Dimon -infile_pat "$dir_raw/${run}_SBREF/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
					-gert_outdir $dir_output -gert_quit_on_err
				3dWarp -deoblique -prefix $fin $dir_output/temp+orig
				rm $dir_output/temp* $dir_output/GERT_Reco_dicom* $dir_output/dimon*
			endif
		end
		### T1
		set fin = $dir_output/$subj.MPRAGE.nii
		if ( ! -f $fin ) then
			cd $dir_output
			Dimon -infile_pat "$dir_raw/MPRAGE/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
				-gert_outdir $dir_output -gert_quit_on_err
			3dWarp -deoblique -prefix $fin $dir_output/temp+orig
			rm $dir_output/temp* $dir_output/GERT_Reco_dicom* $dir_output/dimon*
		endif
	end
end
