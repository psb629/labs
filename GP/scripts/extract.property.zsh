#!/bin/zsh

##===========================================##
 #dir_root=/mnt/ext6/GP/fmri_data/stats/AM/reward
 #
 #list_subj=(`ls $dir_root | grep GP`)
 # #list_subj=('GL03')
 #coord="tlrc"
 #foreach subj ($list_subj)
 #	foreach prop ("rwdtm#2_Coef" "rwdtm#2_Tstat")
 #		3dcalc -prefix $dir_root/$subj/$subj.$prop.$coord.nii \
 #			-a $dir_root/$subj/statsRWDtime.$subj.SPMG2+$coord.HEAD"[$prop]" -expr 'a'
 #	end
 #end
##===========================================##
 #dir_root=/mnt/ext6/GP/fmri_data/stats/GLM.reward.5s_shifted
 #list_subj=(`find $dir_root -type d -name "GP??" | sed "s;$dir_root/;;g"`)
 #
 ## 'Rew#1_Coef'
 #for subj in $list_subj
 #	for prop in 'Rew#1_Coef' 'Rew#1_Tstat'
 #		3dcalc -prefix $dir_root/$subj/$subj.$prop.nii \
 #			-a $dir_root/$subj/stats.$subj+tlrc.HEAD"[$prop]" -expr 'a'
##===========================================##
dir_root=/mnt/ext2/GP/fmri_data/stats/GLM.movement.0s_shifted
list_subj=(`find $dir_root -type d -name "GP??" | sed "s;$dir_root/;;g"`)

for subj in $list_subj
	for prop in 'Length#1_Coef' 'Length#1_Tstat'
		3dcalc -prefix $dir_root/$subj/$subj.$prop.nii \
			-a $dir_root/$subj/stats.$subj+tlrc.HEAD"[$prop]" -expr 'a'
