#!/bin/tcsh


set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

set from_dir = /Volumes/clmnlab/GL
set to_dir = /Volumes/WD_HDD1/GL

if ( ! -d $to_dir ) then
	mkdir -m 755 $to_dir
endif

## behav_data
 #echo "Copying behav_data..."
 #set output_dir = $to_dir/behav_data
 #if ( ! -d $output_dir ) then
 #	mkdir -m 755 $output_dir
 #endif
 #cp -r $from_dir/behavior_data/* $output_dir

# =========================================================
## log_raw file
 #set leaf_list = (MPRAGE r01 r02 r03 r04 r05 r06 r07)
 #set output_dir = $to_dir/fmri_data/raw_data
 #if ( ! -d $output_dir ) then
 #	mkdir -p -m 755 $output_dir
 #endif
 #set log_raw = $output_dir/backup_log.txt
 #if ( -e $log_raw ) then
 #	rm $log_raw
 #endif
 #echo `date` >$log_raw
 #
 ### backup
 #foreach ss ($subj_list)
 #	set subj = GL${ss}
 #	echo "## processing $subj..." >>$log_raw
 #	du -sh $from_dir/fmri_data/$subj/* >>$log_raw
 #	foreach leaf ($leaf_list)
 #		## raw dicom
 #		set from = $from_dir/fmri_data/$subj/$leaf
 #		if ( -d $from ) then
 #			set to = $to_dir/fmri_data/raw_data/$subj/$leaf
 #			if ( ! -d $to ) then
 #				mkdir -p -m 755 $to
 #			endif
 #			cp -r $from/*.IMA $to
 #		else
 #			echo " $from doesn't exist!" >>$log_raw
 #		endif
 #	end
 #end
# =========================================================
## log_preproc file
set output_dir = $to_dir/fmri_data/preproc_data
if ( ! -d $output_dir ) then
	mkdir -p -m 755 $output_dir
endif
set log_preproc = $output_dir/backup_log.txt
if ( -e $log_preproc ) then
	rm $log_preproc
endif
echo `date` >$log_preproc

## backup
foreach ss ($subj_list)
	set subj = GL${ss}
	echo "## processing $subj..." >>$log_preproc
	du -sh $from_dir/fmri_data/$subj/* >>$log_preproc
	## T1
	set from = $from_dir/fmri_data/$subj/$subj.MPRAGE+orig
	if ( -e $from.HEAD ) then
		set to = $to_dir/fmri_data/preproc_data/$subj
		if ( ! -d $to ) then
			mkdir -p -m 755 $to
		endif
		cp $from.* $to
	else
		echo " $from doesn't exist!" >>$log_preproc
	endif
	## epi
	foreach run (`count -digits 2 1 7`)
		set from = $from_dir/fmri_data/$subj/func.$subj.r$run+orig
		if ( -e $from.HEAD ) then
			set to = $to_dir/fmri_data/preproc_data/$subj
			if ( ! -d $to ) then
				mkdir -p -m 755 $to
			endif
			cp $from.* $to
		else
			echo " $from doesn't exist!" >>$log_preproc
		endif
	end
end
