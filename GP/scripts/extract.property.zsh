#!/bin/zsh

dir_root=/mnt/ext6/GP/fmri_data/stats/AM/reward

list_subj=(`ls $dir_root | grep GP`)
 #list_subj=('GL03')
coord="tlrc"
##===========================================##
foreach subj ($list_subj)
	foreach prop ("rwdtm#2_Coef" "rwdtm#2_Tstat")
		3dcalc -prefix $dir_root/$subj/$subj.$prop.$coord.nii \
			-a $dir_root/$subj/statsRWDtime.$subj.SPMG2+$coord.HEAD"[$prop]" -expr 'a'
	end
end
