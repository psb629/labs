#!/bin/zsh

list_nn=( 08 09 10 11 17 \
		  18 19 20 21 22 \
		  24 26 27 32 33 \
		  34 35 36 37 38 \
		  39 40 41 42 43 \
		  44 45 46 47 48 \
		  49 50 51 53 54 \
		  55 )

dir_root="/mnt/sda2/GP/fmri_data"
dir_mask="/mnt/ext4/GP/fmri_data/masks"

dir_stat="$dir_root/stats/GLM.move-stop"
dir_output="$dir_stat"

foreach nn ($list_nn)
	setA=($setA $dir_stat/GP$nn/GP$nn.stat.move-stop+tlrc.HEAD'[Move-Stop_GLT#0_Coef]')
end
cd $dir_output
3dttest++ -mask $dir_mask/full_mask.GP.group.nii\
	-setA $setA \
	-prefix GP.Zscore.n36.nii \
	-ClustSim 10
