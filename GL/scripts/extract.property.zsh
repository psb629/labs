#!/bin/zsh

dir_root=/mnt/sdb2/GL/fmri_data/stats/GLM.reward

list_subj=(`ls $dir_root | grep GL`)
 #list_subj=('GL03')

coord="tlrc"
##===========================================##
foreach subj ($list_subj)
	foreach prop ("Rew#1_Coef" "Rew#1_Tstat")
		3dcalc -prefix $dir_root/$subj/$subj.$prop.$coord.nii \
			-a $dir_root/$subj/stats.$subj+$coord.HEAD"[$prop]" -expr 'a'
	end
end
