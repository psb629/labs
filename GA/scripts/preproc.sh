#!/bin/tcsh
set res = 2.683
set fwhm = 4
set thresh_motion = 0.4
# ===================================================
set id_list = (GA GB)
set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
set subj_list = ( 01 )
set run_list = (r01 r02 r03 r04 r05 r06)
# ===================================================
set root_dir = /Volumes/WD_HDD1/GA
set raw_dir = $root_dir/fmri_data/raw_data
# ===================================================
set cnt = 0
foreach ii ($id_list)
	foreach nn ($subj_list)
		set subj = $ii$nn
		set output_dir = /Users/clmn/Desktop/GA/fmri_data/preproc_data/$nn
		if ( ! -d $output_dir ) then
			mkdir -p -m 755 $output_dir
		endif
		###############################################################################
		########
		# anat #
		########
		# ================================= setp 00 : convert =================================
		Dimon -infile_pat "$raw_dir/$subj/MPRAGE/*.IMA" -gert_create_dataset \
		-gert_to3d_prefix temp -gert_outdir $output_dir -gert_quit_on_err
		3dWarp -deoblique -prefix $output_dir/$subj.MPRAGE $output_dir/temp+orig
		rm $output_dir/temp*
		###############################################################################
		########
		# fMRI #
		########
		# ================================= setp 00 : convert =================================
		if (-e $raw_dir/$subj/dist_PA) then
			Dimon -infile_pat "$raw_dir/$subj/dist_PA/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
			-gert_outdir $output_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $output_dir/$subj.dist.PA $output_dir/temp+orig
			rm $output_dir/temp*
		endif
		if (-e $raw_dir/$subj/dist_AP) then
			Dimon -infile_pat "$raw_dir/$subj/dist_AP/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
			-gert_outdir $output_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $output_dir/$subj.dist.AP $output_dir/temp+orig
			rm $output_dir/temp*
		endif
		foreach run ($run_list)
			Dimon -infile_pat "$raw_dir/$subj/$run/*.IMA" -gert_create_dataset -gert_to3d_prefix temp \
			-gert_outdir $output_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $output_dir/$subj.func.$run $output_dir/temp+orig
			rm $output_dir/temp*
		end
		###############################################################################
		echo "subject $subj completed!"
	end
end
