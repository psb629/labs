#!/bin/zsh

dir_root=/mnt/ext6/GP/fmri_data
dir_stat=$dir_root/stats/AM/reward

list_subj=(`ls $dir_stat | grep '^GP[0-9][0-9]'`)

 #conda activate GA
##===========================================##
foreach subj ($list_subj)
 #	foreach prop ("Move-Stop_GLT#0_Coef" "Move-Stop_GLT#0_Tstat")
 #		3dcalc -prefix $subj/$subj.$prop.$coord.nii \
 #			-a $subj/statMove.$subj+$coord.HEAD"[$prop]" -expr 'a'
 #	end
 #	tstat="$dir_stat/$subj/statsRWDtime.$subj.SPMG2+tlrc.HEAD[rwdtm#2_Tstat]"
	tstat="$dir_stat/$subj/$subj.rwdtm#2_Tstat.tlrc.nii"
	dof=`3dinfo -verb $tstat | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
	TtoZ --t_stat_map=$tstat --dof=$dof --output_nii="$dir_stat/$subj/$subj.rwdtm#2_Zstat.tlrc.nii"
end
