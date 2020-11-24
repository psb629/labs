#!/bin/tcsh


set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
set from_dir = /Volumes/clmnlab/GA
set to_dir = /Volumes/WD_HDD1/GA

if ( ! -d $to_dir ) then
	mkdir -m 755 $to_dir
endif

## log_raw file
set leaf_list = (64CH_LOCALIZER_0001 dist_AP dist_PA rest rest_SBREF MPRAGE r00 r00_SBREF r01 r01_SBREF r02 r02_SBREF r03 r03_SBREF r04 r04_SBREF r05 r05_SBREF r06 r06_SBREF r07 r07_SBREF)
set log_raw = $to_dir/fmri_data/raw_data/backup_log.txt
if ( -e $log_raw ) then
	rm $log_raw
endif
echo `date` >$log_raw

## behav_data
 #echo "Copying behav_data..."
 #set output_dir = $to_dir/behav_data
 #if ( ! -d $output_dir ) then
 #	mkdir -m 755 $output_dir
 #endif
 #cp -r $from_dir/behavior_data/* $output_dir

## revision_data
 #echo "Copying revision_data..."
 #set output_dir = $to_dir/revision
 #if ( ! -d $output_dir ) then
 #	mkdir -m 755 $output_dir
 #endif
 #cp -r $from_dir/Revision/* $output_dir

foreach id (GA GB GC)
	foreach ss ($subj_list)
		set subj = ${id}${ss}
		echo "## processing $subj..." >>$log_raw
		du -sh $from_dir/fMRI_data/raw_data/$subj/* >>$log_raw
		foreach leaf ($leaf_list)
			## raw dicom
			set from = $from_dir/fMRI_data/raw_data/$subj/$leaf
			if ( -d $from ) then
				set to = $to_dir/fmri_data/raw_data/$subj/$leaf
				if ( ! -d $to ) then
					mkdir -p -m 755 $to
				endif
				cp -r $from/*.IMA $to
			else
				echo " $from doesn't exist!" >>$log_raw
			endif
		end
	end
end
