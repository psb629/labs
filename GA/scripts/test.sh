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
 #		pname=$to_dir/stats.MO.shotrdur.4target.$subj.run1to3.nii.gz
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
