#!/bin/tcsh


set subj_list = (11 07 30 02 29 32 23 01 31 33 20 44 26 15 38)

#===========================================================================
set to_dir = ~/Desktop/GD/fmri_data/preproc_data
if ( ! -d $to_dir ) then
	mkdir -p -m 755 $to_dir
endif

## log file
set log = $to_dir/backup_log.txt
echo "## `users`: `date`" >>$log

## backup the raw data
foreach nn ($subj_list)
	set subj = GD$nn
	echo "## ============================================== ##" >>$log
	echo "processing $subj..." >>$log

	set from_dir = /Volumes/clmnlab/GD/fMRI_data/preproc_data/$subj
	cd $from_dir

	## count regular files
	echo "# of files : `ls -l | grep ^- | wc -l`" >>$log

	## creates a list of files, excluding directories at the current location.
	ls -p | grep -v / >>$log
 #	ls -a -tr | grep -v '^\.' >>$backup_log

	set from = `ls -p | grep -v /`

	set to = $to_dir/$subj
	if ( ! -d $to ) then
		mkdir -p -m 755 $to
	endif

	cp $from $to/
end
#===========================================================================
