#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )

# ==================================================================
## copy ANOVA data
 #from_dir=/Volumes/clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data_4target/run1to3/group
 #to_dir=/Volumes/T7SSD1/GA/fMRI_data/stats/ANOVA
 #if [ ! -d $to_dir ]; then
 #	mkdir -p -m 755 $to_dir
 #fi
 #foreach ii (GA GB)
## ANOVA
 #	from=$from_dir/ANOVA.MO.shortdur.4target.Target.$ii+tlrc
 #	pname=$to_dir/ANOVA.MO.shortdur.4target.${ii}s.nii.gz
 #	if [ ! -e $pname ]; then
 #		3dAFNItoNIFTI -prefix $pname $from
 #	fi
## ANOVA_fstat
 #	from=$from_dir/ANOVA_MO_shortdur_4target_Target_${ii}_fstat.nii.gz
 #	to=$to_dir/ANOVA.MO.shortdur.4target.${ii}s.fstat.nii.gz
 #	if [ ! -e $to ]; then
 #		cp $from $to
 #	fi
 #end
# ==================================================================
## copy 4targets_regressors
 #from_dir=/Volumes/clmnlab/GA/fmri_data/regressors/reg_4targets/
 #to_dir=/Volumes/T7SSD1/GA/behav_data/regressors/4targets
 #if [ ! -d $to_dir ]; then
 #	mkdir -p -m 755 $to_dir
 #fi
 #
 #foreach ii (GA GB)
 #	foreach nn ($nn_list)
 #		subj=$ii$nn
 #		foreach tt (1 5 21 25)
 #			from=$from_dir/GA$nn/GA${nn}_${ii}_onset_prac_target$tt.txt
 #			if [ ! -e $from ]; then
 #				echo " $from doesn't exist!"
 #				continue
 #			fi
 #			to=$to_dir/$subj.onset.prac.target$tt.txt
 #			cp $from $to
 #		end
 #	end
 #end
# ==================================================================
## GLM results about 4 targets
 #from_dir=/Volumes/clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data_4target/run1to3/stats
 #to_dir=/Volumes/T7SSD1/GA/fMRI_data/stats/Reg4_GLM_4targets
 #if [ ! -d $to_dir ]; then
 #	mkdir -p -m 755 $to_dir
 #fi
 #
 #foreach ii (GA GB)
 #	foreach nn ($nn_list)
 #		subj=$ii$nn
 #		from=$from_dir/stats.MO.shortdur.4target.$subj.run1to3+tlrc
 #		pname=$to_dir/stats.MO.shortdur.4target.$subj.run1to3.nii.gz
 #		3dAFNItoNIFTI -prefix $pname $from
 #		if [ ! -e $to ]; then
 #			echo " $from doesn't exist!"
 #			continue
 #		fi
 #	end
 #end
# ==================================================================
## copy displacement_regressor for MO
 #from_dir=/Volumes/clmnlab/GA/regressors/reg_onset_displacement/AM1_reg_disp_convolve/
 #to_dir=/Volumes/T7SSD1/GA/behav_data/regressors/displacement
 #if [ ! -d $to_dir ]; then
 #	mkdir -p -m 755 $to_dir
 #fi
 #
 #foreach ii (GA GB)
 #	foreach nn ($nn_list)
 #		subj=$ii$nn
 #		from=$from_dir/AM1.disp.ideal.$subj.run1to3.xmat.1D
 #		to=$to_dir/$subj.onset.AM1.disp.ideal.run1to3.xmat.1D
 #		if [ ! -e $from ]; then
 #			echo " $from doesn't exist!"
 #			continue
 #		fi
 #		cp $from $to
 #	end
 #end
# ==================================================================
## copy design matrix of 3dLSS
 #from_dir=/Volumes/clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data_xmat_201910
 #to_dir=/Volumes/T7SSD1/GA/fMRI_data/preproc_data
 #if [ ! -d $to_dir ]; then
 #	mkdir -p -m 755 $to_dir
 #fi
 ### backup log file
 #backup_log=$to_dir/backup_log.txt
 #
 #echo "## `users`: `date`" >>$backup_log
 #echo "## copy design matrix of 3dLSS" >>$backup_log
 #echo "### list of absences" >>$backup_log
 #foreach nn ($nn_list)
 #	foreach ss (GB)
 #		foreach rr (`count -digits 2 1 6`)
 #			## design matrix
 #			from=$from_dir/X.xmatLSS.MO.shortdur.${ss}${nn}.r${rr}.1D
 #			if [ ! -e $from ]; then
 #				echo " $from doesn't exist!" >>$backup_log
 #				continue
 #			fi
 #			to=$to_dir/${nn}/X.xmatLSS.MO.shortdur.${ss}${nn}.r${rr}.1D
 #			cp $from $to
 #		end
 #	end
 #end
# ==================================================================
## copy 4-target regressors
 #from_dir=/Volumes/clmnlab/GA/regressors
 #to_dir=/Volumes/T7SSD1/GA/behav_data/regressors/4targets
 #if [ ! -d $to_dir ]; then
 #	mkdir -p -m 755 $to_dir
 #fi
 ### backup log file
 #backup_log=$to_dir/backup_log.txt
 #
 #echo "## `users`: `date`" >>$backup_log
 #echo "## copy 4-target regressors" >>$backup_log
 #echo "### list of absences" >>$backup_log
 #foreach nn ($nn_list)
 #	foreach ss (GA GB)
 #		foreach rr (`count -digits 2 1 6`)
 #			## onsets
 #			from=$from_dir/LSS_reg_center/${ss}${nn}/${ss}${nn}_onsettime.r${rr}.txt
 #			if [ ! -e $from ]; then
 #				echo " $from doesn't exist!" >>$backup_log
 #				continue
 #			fi
 #			to=$to_dir/${ss}${nn}.onset.4targets.r${rr}.txt
 #			cp $from $to
 #
 #			## amplitudes, I don't know what exactly it is.
 #			from=$from_dir/reg_onset_displacement/${ss}${nn}/${ss}${nn}_amplitude_r${rr}.txt
 #			if [ ! -e $from ]; then
 #				echo " $from doesn't exist!" >>$backup_log
 #				continue
 #			fi
 #			to=$to_dir/${ss}${nn}.amplitude.4targets.r${rr}.txt
 #			cp $from $to
 #
 #			## AMregressors
 #			from=$from_dir/reg_onset_displacement/AM2_reg/AMregressor_disp_${ss}${nn}_r${rr}.1D
 #			if [ ! -e $from ]; then
 #				echo " $from doesn't exist!" >>$backup_log
 #				continue
 #			fi
 #			to=$to_dir/${ss}${nn}.AMregressor.4targets.r${rr}.1D
 #			cp $from $to
 #		end
 #	end
 #end
# ==================================================================
## upload pb02s to Google Drive
nn_list=( 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
gdrive=/Volumes/GoogleDrive/내\ 드라이브/GA/pb02

from_dir=/Volumes/clmnlab/GA/fmri_data/preproc_data
to_dir=~/Desktop/pb02
if [ ! -d $to_dir ]; then
	mkdir -p -m 755 $to_dir
fi
### log_file ###
log_file=$to_dir/log.txt

echo "## start time (`users`): `date`" >>$log_file
echo "## upload pb02s to Google Drive" >>$log_file
echo "### list of absences" >>$log_file

foreach gg (GA GB)
	foreach nn ($nn_list)
		subj=${gg}${nn}
		foreach rr (`count -digits 2 0 6`)
			from=$from_dir/$subj/pb02.$subj.r$rr.volreg+tlrc
			if [ ! -f $from.HEAD ]; then
				echo " $from doesn't exist!" >>$log_file
				continue
			fi
			if [ $rr -eq 00 ]; then
				to=$to_dir/pb02.$subj.localizer.volreg.nii.gz
			else;
				to=$to_dir/pb02.$subj.r$rr.volreg.nii.gz
			fi
			3dAFNItoNIFTI -prefix $to $from
			cp $to $gdrive
			rm $to
		end
	end
end
echo "## end time (`users`): `date`" >>$log_file
cp $log_file $gdrive
rm $log_file
