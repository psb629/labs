#!/bin/tcsh


set subj_list = ( 01 02 05 07 08 \
				  11 12 13 14 15 \
				  18 19 20 21 23 \
				  26 27 28 29 30 \
				  31 32 33 34 35 \
				  36 37 38 42 44 )
set from_dir = /Volumes/clmnlab/GA/fmri_data/original-space_preproc_data
set to_dir = /Volumes/WD_HDD1/GA/fmri_data/preproc_data

if ( ! -d $to_dir ) then
	mkdir -p -m 755 $to_dir
endif

## log_preproc file
set log_preproc = $to_dir/backup_log.txt
if ( -e $log_preproc ) then
	rm $log_preproc
endif
echo `date` >$log_preproc

foreach id (GA GB GC)
	foreach ss ($subj_list)
		set subj = ${id}${ss}
		echo "## processing $subj..." >>$log_preproc
		## preproc_data
		set from = $from_dir/$id/$subj
		du -sh $from/* >>$log_preproc
		if ( -d $from ) then
			set to = $to_dir/$subj
			if ( ! -d $to ) then
				mkdir -m 755 $to
			endif
			cp -r $from/* $to
		else
			echo " $from doesn't exist!" >>$log_preproc
		endif
	end
end
