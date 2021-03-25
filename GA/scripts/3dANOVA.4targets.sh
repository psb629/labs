#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )

root_dir=/Volumes/T7SSD1/GA/fMRI_data
data_dir=$root_dir/stats/Reg4_GLM_4targets
gmask=$root_dir/roi/full_mask.GAGB.nii.gz
output_dir=$root_dir/stats/ANOVA
if [ ! -d $output_dir ]; then
	mkdir -p -m 755 $output_dir
fi

foreach ii (GA GB)
	temp=("-mask $gmask")
	temp=($temp "-levels 4")
	cnt=0
	foreach tt (1 5 21 25)
		let cnt+=1
		foreach nn ($nn_list)
			temp=($temp "-dset $cnt $data_dir/stats.MO.shortdur.4target.$ii$nn.run1to3.nii.gz[beta_target$tt#0_Coef]")
		end
		temp=($temp "-mean $cnt Target$tt")
	end
 	temp=($temp "-ftr Target")
	temp=($temp "-diff 1 2 T1_vs_T5")
	temp=($temp "-diff 1 3 T1_vs_T21")
	temp=($temp "-diff 1 4 T1_vs_T25")
	temp=($temp "-diff 2 3 T5_vs_T21")
	temp=($temp "-diff 2 4 T5_vs_T25")
	temp=($temp "-diff 3 4 T21_vs_T25")
	temp=($temp "-contr 1 -1 0 0 T1-T5")
	temp=($temp "-contr 1 0 -1 0 T1-T21")
	temp=($temp "-contr 1 0 0 -1 T1-T25")
	temp=($temp "-contr 0 1 -1 0 T5-T21")
	temp=($temp "-contr 0 1 0 -1 T5-T25")
	temp=($temp "-contr 0 0 1 -1 T21-T25")
 	temp=($temp "-contr 3 -1 -1 -1 3*T1-T5-T21-T25")
 	temp=($temp "-contr -1 3 -1 -1 3*T5-T1-T21-T25")
 	temp=($temp "-contr -1 -1 3 -1 3*T21-T1-T5-T25")
 	temp=($temp "-contr -1 -1 -1 3 3*T25-T1-T5-T21")
	temp=($temp "-bucket $output_dir/ANOVA.$ii.MO.shortdur.4target")
	3dANOVA `echo $temp`
 #	echo $temp
 #3dAFNItoNIFTI -prefix ANOVA_MO_shortdur_4target_Target_GB_fstat.nii.gz ANOVA.MO.shortdur.4target.Target.GB+tlrc'[Target:F-stat]'
end
