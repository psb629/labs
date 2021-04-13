#!/bin/tcsh


set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
#===========================================================================
 #set from_dir = /Volumes/clmnlab/GA/behavior_data
 #set to_dir = /Volumes/T7SSD1/GA/behav_data/regressors/move-stop
 #
 #if ( ! -d $to_dir ) then
 #	mkdir -p -m 755 $to_dir
 #endif
 #
 ### backup log file
 #set backup_log = $to_dir/backup_log.txt
 #if ( -e $backup_log ) then
 #	rm $backup_log
 #endif
 #
 #echo "## `users`: `date`" >>$backup_log
 #foreach nn ($subj_list)
 #	foreach ss (Move Stop)
 #		## regressors
 #		set from = $from_dir/GA$nn/GA${nn}_${ss}.txt
 #		if ( ! -e $from ) then
 #			echo " $from doesn't exist!" >>$backup_log
 #			continue
 #		endif
 #		set to = $to_dir/${nn}_${ss}.txt
 #		cp $from $to
 #	end
 #end
#===========================================================================
