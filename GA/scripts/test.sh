#!/bin/tcsh

set temp = (GD11 GD07 GD30 GD02 GD32 GD23 GD01 GD33 GD20 GD44 GD26 GD15)
set subj_list = `echo $temp | sed "s/D/A/g"`
echo $subj_list

set subj_list = ( GA01 GA02 GA05 GA07 GA08 \
				  GA11 GA12 GA13 GA14 GA15 \
				  GA18 GA19 GA20 GA21 GA23 \
				  GA26 GA27 GA28 GA29 GA30 \
				  GA31 GA32 GA33 GA34 GA35 \
				  GA36 GA37 GA38 GA42 GA44 )
set ori_dir = /Volumes/clmnlab/GA/behavior_data
set obj_dir = /Volumes/T7SSD1/GA/behav_data

 #foreach a ($subj_list)
 #	cp $ori_dir/$subj/$subj-fmri.mat $obj_dir/
 #	cp $ori_dir/$subj/$subj-refmri.mat $obj_dir/
 #	set subj = `echo $a | sed "s/A/B/g"`
 #	set temp = $obj_dir/regressors/$subj
 #	mkdir $temp
 #	foreach run (r01 r02 r03 r04 r05 r06 r07)
 #	 	cp $ori_dir/$subj/$subj.${run}rew1000.GAM.1D $temp
 #	end
 #end
 #foreach subj ($subj_list)
 #	set full_mask_file = /Volumes/clmnlab/GA/fmri_data/preproc_data/$subj/full_mask.{$subj}+tlrc.
 #	set pname = /Volumes/T7SSD1/GA/fMRI_data/masks/full/full_mask.{$subj}.nii.gz
 #	3dAFNItoNIFTI -prefix $pname $full_mask_file
 #end

# ============================================================
set ori_dir = /Volumes/clmnlab/GA/fmri_data/glm_results/am_reg_SPMG2/stats
set early_dir = /Volumes/T7SSD1/GA/fMRI_data/stats/fig4/early
set late_dir = /Volumes/T7SSD1/GA/fMRI_data/stats/fig4/late

foreach subj ($subj_list)
 #	3dAFNItoNIFTI -prefix $early_dir/statsRWDtime.$subj.run1to3.SPMG2.nii.gz $ori_dir/statsRWDtime.$subj.run1to3.SPMG2+tlrc.
	3dAFNItoNIFTI -prefix $early_dir/statsRWDtime.$subj.run4to6.SPMG2.nii.gz $ori_dir/statsRWDtime.$subj.run4to6.SPMG2+tlrc.
	set temp = `echo $subj | sed "s/A/B/g"`
 #	3dAFNItoNIFTI -prefix $late_dir/statsRWDtime.$subj.run1to3.SPMG2.nii.gz $ori_dir/statsRWDtime.$temp.run1to3.SPMG2+tlrc.
	3dAFNItoNIFTI -prefix $late_dir/statsRWDtime.$subj.run4to6.SPMG2.nii.gz $ori_dir/statsRWDtime.$temp.run4to6.SPMG2+tlrc.
end
# ============================================================