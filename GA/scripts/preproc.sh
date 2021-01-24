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
 #		set output_dir = /Users/clmn/Desktop/GA/fmri_data/preproc_data/$nn
		set output_dir = /Volumes/WD_HDD1/test/GA/fmri_data/preproc_data/$nn
		if ( ! -d $output_dir ) then
			mkdir -p -m 755 $output_dir
		endif
		###############################################################################
		########
		# anat #
		########
		# ================================= setp 00 : convert =================================
		cd $output_dir
		set pname = T1.3D.$subj
		Dimon -infile_pat "$raw_dir/$subj/MPRAGE/*.IMA" \
			-gert_create_dataset -gert_to3d_prefix $pname \
			-gert_outdir $output_dir -gert_quit_on_err
		3dWarp -deoblique -prefix $output_dir/$subj.MPRAGE $output_dir/$pname+orig
		rm $output_dir/GERT_Reco_dicom_* $output_dir/dimon.files.run.* $output_dir/${pname}*
		# ================================= setp 01 : tcat and tshift (pb00) =================================
		# tcat은 각 시간의 volume(sub-brick) 데이터를 시간에 대해 catenate 해준다는 뜻. 시간을 포함한 4차원 데이터로 merge.
		# apply 3dTcat to copy input dsets to results dir, while
		# removing the first 0 TRs
		3dcopy $output_dir/$subj.MPRAGE+orig $output_dir/preprocessed/$subj.anat+orig
		# Will copy only the dataset with the given view (orig, acpc, tlrc).

		###############################################################################
		########
		# fMRI #
		########
		# ================================= setp 00 : convert =================================
		if (-e $raw_dir/$subj/dist_PA) then
			cd $output_dir
			set pname = PA.3D.$subj
			Dimon -infile_pat "$raw_dir/$subj/dist_PA/*.IMA" \
				-gert_create_dataset -gert_to3d_prefix $pname \
				-gert_outdir $output_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $output_dir/$subj.dist.PA $output_dir/$pname+orig
			rm $output_dir/GERT_Reco_dicom_* $output_dir/dimon.files.run.* $output_dir/${pname}*
		endif
		if (-e $raw_dir/$subj/dist_AP) then
			cd $output_dir
			set pname = AP.3D.$subj
			Dimon -infile_pat "$raw_dir/$subj/dist_AP/*.IMA" \
				-gert_create_dataset -gert_to3d_prefix $pname \
				-gert_outdir $output_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $output_dir/$subj.dist.AP $output_dir/$pname+orig
			rm $output_dir/GERT_Reco_dicom_* $output_dir/dimon.files.run.* $output_dir/${pname}*
		endif
		foreach run ($run_list)
			cd $output_dir
			set pname = $run.3D.$subj
			Dimon -infile_pat "$raw_dir/$subj/$run/*.IMA" \
				-gert_create_dataset -gert_to3d_prefix $pname \
				-gert_outdir $output_dir -gert_quit_on_err
			3dWarp -deoblique -prefix $output_dir/$subj.func.$run $output_dir/$pname+orig
			rm $output_dir/GERT_Reco_dicom_* $output_dir/dimon.files.run.* $output_dir/${pname}*
		end
		# ================================= setp 01 : tcat and tshift (pb00) =================================
		# tcat은 각 시간의 volume(sub-brick) 데이터를 시간에 대해 catenate 해준다는 뜻. 시간을 포함한 4차원 데이터로 merge.
		# apply 3dTcat to copy input dsets to results dir, while
		# removing the first 0 TRs
		foreach run ($run_list)
			3dTcat -prefix $output_dir/preprocessed/$subj.pb00.$run.tcat $output_dir/$subj.func.$run+orig'[0..$]'
		end
		# if you want to remove the first 2 TRs (TR indices 0 and 1), use [2..$] instead of [0..$]
		# 2..$ -> $는 just a variable which means the very end of that array. Only keeping volumes two to the very end 라는 뜻.
		# ========================== auto block: outcount ==========================
		# data check: compute outlier fraction for each volume
		# Calculate number of 'outliers' a 3D+time dataset, at each time point, and writes the results to stdout.
		# outliers -> MAD (Mean Absolute Deviation). If the MAD is 10, that means that at the RT we have an average of five median absolute deviations from the mean.
		# Usually about 5.5 MAD is considered an outlier.
		touch $output_dir/preprocessed/$subj.out.pre_ss_warn.txt
		set npol = 4
		foreach run ($run_list)
			# The formula that we use for polort, which is applied by afni_proc.py and by "3dDeconvolve -polort A", is pnum = 1 + floor(run_duration/150), where times are in seconds. 
			# Yes, pnum would be the order of polynomial used in 3dToutcount or 3dDeconvolve, while run_duration is the duration of the run in seconds (regardless of the number of time points).
			# if scanning time = 420s, so npol = 3
			3dToutcount -automask -fraction -polort $npol -legendre \
				$output_dir/preprocessed/$subj.pb00.$run.tcat+orig > $output_dir/preprocessed/$subj.outcount.$run.1D
			# outliers at TR 0 might suggest pre-steady state TRs
			# -fraction option to 3dToutcount, so that the output is no longer a voxel count,
			# but is that count divided by the number of voxels in the computed automask
			# -fraction  = Output the fraction of (masked) voxels which are outliers at each time point, instead of the count.
			# -polort nn = Detrend each voxel time series with polynomials of order 'nn' prior to outlier estimation.
			if ( `1deval -a $output_dir/preprocessed/$subj.outcount.$run.1D"{0}" -expr "step(a-0.4)"` ) then
				echo "** TR #0 outliers: possible pre-steady state TRs in run ${run}" >> $output_dir/preprocessed/$subj.out.pre_ss_warn.txt
			endif
		end
		# catenate outlier counts into a single time series
		cat $output_dir/preprocessed/$subj.outcount.r*.1D > $output_dir/preprocessed/$subj.outcount_rall.1D
		# in Terminal,
		# cat outcount_rall.1D  'SHOWS' the fraction of outliers for the total individual time points.
		# 1dplot outcount_rall.1D  'SHOWS'  the graph of outliers with x-axis time, y-axis the fraction value.
		# 1deval -a outcount_rall.1D -expr 't * step(a-0.05)' | grep -v '0'
		# -> '~' = certain threshold. Any TRs which are greater than 0.05 or TRs which have more than 5% of the voxels as outliers
		# -> grep -v '0'  = only look at nonzero entries
		# 1dplot -one '1D: 450@0.05' outcount_rall.1D -> x축은 0부터 450까지, 높이 0.05인 직선을 그어서 0.05 이상의 outlier가 어디인지 그래프로 확인.
		# AFNI에서는 pb00.~.tcat 파일을 열고 graph 켜서 edge of brain 영역을 확인.
		# Edge of brain gives you a better sense of if there was any head motion contributing to a huge increase in signal.

		###############################################################################
		echo "subject $subj completed!"
	end
end
