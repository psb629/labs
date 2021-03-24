#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )

root_dir = /Volumes/T7SSD1/GA/fMRI_data
data_dir = $root_dir/stats/Reg4_GLM_4targets
gmask = $root_dir/roi/full_mask.GAGB.nii.gz
output_dir = $root_dir/stats/ANOVA
if [ ! -d $output_dir ]; then
	mkdir -p -m 755 $output_dir
fi

foreach ii (GA GB)
	temp=()
	cnt=0
	foreach tt (1 5 21 25)
		cnt+=1
		foreach nn ($nn_list)
			temp=($temp "-dset $cnt $data_dir/stats.MO.shortdur.4target.$ii$nn.run1to3.nii.gz'[beta_target$tt#0_Coef]'")
		end
	end
	echo $temp
end
 #3dANOVA -levels 4 \
 #-dset 1 stats.MO.shortdur.4target.GB01.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB02.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB05.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB07.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB08.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB11.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB12.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB13.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB14.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB15.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB18.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB19.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB20.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB21.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB23.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB26.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB27.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB28.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB29.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB30.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB31.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB32.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB33.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB34.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB35.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB36.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB37.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB38.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB42.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 1 stats.MO.shortdur.4target.GB44.run1to3+tlrc'[beta_target1#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB01.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB02.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB05.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB07.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB08.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB11.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB12.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB13.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB14.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB15.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB18.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB19.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB20.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB21.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB23.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB26.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB27.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB28.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB29.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB30.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB31.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB32.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB33.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB34.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB35.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB36.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB37.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB38.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB42.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 2 stats.MO.shortdur.4target.GB44.run1to3+tlrc'[beta_target5#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB01.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB02.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB05.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB07.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB08.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB11.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB12.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB13.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB14.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB15.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB18.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB19.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB20.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB21.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB23.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB26.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB27.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB28.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB29.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB30.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB31.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB32.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB33.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB34.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB35.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB36.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB37.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB38.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB42.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 3 stats.MO.shortdur.4target.GB44.run1to3+tlrc'[beta_target21#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB01.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB02.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB05.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB07.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB08.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB11.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB12.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB13.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB14.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB15.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB18.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB19.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB20.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB21.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB23.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB26.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB27.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB28.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB29.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB30.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB31.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB32.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB33.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB34.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB35.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB36.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB37.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB38.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB42.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-dset 4 stats.MO.shortdur.4target.GB44.run1to3+tlrc'[beta_target25#0_Coef]' \
 #-ftr Target \
 #-mean 1 Target1 \
 #-mean 2 Target5 \
 #-mean 3 Target21 \
 #-mean 4 Target25 \
 #-diff 1 2 Target1_vs_Target5 \
 #-diff 1 3 Target1_vs_Target21 \
 #-diff 1 4 Target1_vs_Target25 \
 #-diff 2 3 Target5_vs_Target21 \
 #-diff 3 4 Target21_vs_Target25 \
 #-contr 1 -1 0 0 Target1-Target5 \
 #-contr 1 0 -1 0 Target1-Target21 \
 #-contr 1 0 0 -1 Target1-Target25 \
 #-contr 0 1 -1 0 Target5-Target21 \
 #-contr 0 0 1 -1 Target21-Target25 \
 #-contr 1 1 1 1 Target1+5+21+25 \
 #-contr 3 -1 -1 -1 3*Target1-5-21-25 \
 #-contr -1 3 -1 -1 3*Target5-1-21-25 \
 #-contr -1 -1 3 -1 3*Target21-1-5-25 \
 #-contr -1 -1 -1 3 3*Target25-1-5-21 \
 #-mask '/clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30+tlrc.HEAD' \
 #-bucket ANOVA.MO.shortdur.4target.Target.GB
 #
 #3dAFNItoNIFTI -prefix ANOVA_MO_shortdur_4target_Target_GB_fstat.nii.gz ANOVA.MO.shortdur.4target.Target.GB+tlrc'[Target:F-stat]'
