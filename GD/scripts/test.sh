#!/bin/tcsh

set subj = GD01
echo $subj | sed "s/D/A/g"

set subj_list = ( GA01 GA02 GA05 GA07 GA08 \
				  GA11 GA12 GA13 GA14 GA15 \
				  GA18 GA19 GA20 GA21 GA23 \
				  GA26 GA27 GA28 GA29 GA30 \
				  GA31 GA32 GA33 GA34 GA35 \
				  GA36 GA37 GA38 GA42 GA44 )

set ori_dir = /Volumes/clmnlab/GA/behavior_data/
set obj_dir = /Volumes/T7SSD1/GA/behav_data

 #foreach subj ($subj_list)
 #	cp $ori_dir/$subj/$subj-fmri.mat $obj_dir/
 #	cp $ori_dir/$subj/$subj-refmri.mat $obj_dir/
 #	
 #	set temp = $obj_dir/regressors/$subj
 #	mkdir $temp
 #	foreach run (r01 r02 r03 r04 r05 r06 r07)
 #	 	cp $ori_dir/$subj/$subj.${run}rew1000.GAM.1D $temp
 #	end
 #end
