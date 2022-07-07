#!/bin/zsh

dir_root=/mnt/ext6/GL/fmri_data/stats

list_subj=(`ls $dir_root/GLM.reward | grep '^GL[0-9][0-9]'`)

coord="tlrc"

conda activate GA
##===========================================##
# Move-Stop
cd $dir_root/GLM.Move-Stop
foreach subj ($list_subj)
	foreach prop ("Move-Stop_GLT#0_Coef" "Move-Stop_GLT#0_Tstat")
		3dcalc -prefix $subj.$prop.$coord.nii \
			-a statMove.$subj+$coord.HEAD"[$prop]" -expr 'a'
	end
	TtoZ --t_stat_map="$subj.Move-Stop_GLT#0_Tstat.$coord.nii" --dof=296 --output_nii="$subj.Move-Stop.z_score_map.nii"
end

# Reward
cd $dir_root/GLM.reward
foreach subj ($list_subj)
	foreach prop ("Rew#1_Coef" "Rew#1_Tstat")
		3dcalc -prefix $subj/$subj.$prop.$coord.nii \
			-a $subj/stats.$subj+$coord.HEAD"[$prop]" -expr 'a'
	end
	TtoZ --t_stat_map="$subj/$subj.Rew#1_Tstat.$coord.nii" --dof=1690 --output_nii="$subj/$subj.reward.z_score_map.nii"
end
