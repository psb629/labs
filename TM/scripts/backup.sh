#!/bin/tcsh

set subj_list = ( TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT TML10_PILOT TML11_PILOT \
					TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20 \
					TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29)

# ============================================================
 ### raw_data
 #set from_dir = /Volumes/clmnlab/TM/fMRI_data/raw_data
 #set to_dir = /Volumes/WD_HDD1/TM/fmri_data/raw_data
 #if ( ! -d $to_dir ) then
 #	mkdir -p -m 755 $to_dir
 #endif
 #
 ### backup log file
 # set backup_log = $to_dir/backup_log.txt
 # #echo "## `users`: `date`" >>$backup_log
 # #cd $from_dir
 # #du -sh * >>$backup_log
 #
 ### backup
 #foreach subj ($subj_list)
 #	echo "## ============================================== ##" >>$backup_log
 #	echo "processing $subj..." >>$backup_log
 #
 #	cd $from_dir/$subj
 #	echo "# of directories : `ls -l | grep ^d | wc -l`" >>$backup_log
 #	ls -a -tr | grep -v '^\.' >>$backup_log
 #
 #	set from = $from_dir/$subj
 #	set to = $to_dir/$subj
 #	if ( ! -d $to ) then
 #		mkdir -p -m 755 $to
 #	endif
 #
 #	cp -a $from/. $to
 #end
# ============================================================
## preproc_data
set to_dir = /Volumes/WD_HDD1/TM/fmri_data/preproc_data
if ( ! -d $to_dir ) then
	mkdir -p -m 755 $to_dir
endif

## backup log file
set log = $to_dir/backup_log.txt
echo "## `users`: `date`" >>$log

## backup
foreach subj ($subj_list)
	echo "## ============================================== ##" >>$log
	echo "processing $subj..." >>$log

	set from_dir = /Volumes/clmnlab/TM/fMRI_data/preproc_data/$subj
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
