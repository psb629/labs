#!/bin/zsh

dir_glm=/mnt/sdb2/GL/fmri_data/stats/GLM.Move_Stop

list=(GL03 GL05 GL07 GL09 GL11\
	GL14 GL16 GL18 GL20 GL22\
	GL25 GL27 GL04 GL06 GL08\
	GL10 GL12 GL15 GL17 GL19\
	GL21 GL24 GL26 GL29)

foreach subj ($list)
	3dcalc -prefix "$dir_glm/tmp.$subj.nii" \
		-a $dir_glm/statMove.${subj}+tlrc.HEAD'[Move-Stop_GLT#0_Coef]' -expr 'a'
end

list=(`ls $dir_glm/tmp.GL??.nii`)
cd $dir_glm
3dttest++ -prefix statMove.group.nii -setA $list -ClustSim 10

echo $list | xargs rm
