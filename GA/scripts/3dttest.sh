#!/bin/tcsh

set subj_list = ( GA01 GA02 GA05 GA07 GA08 \
				  GA11 GA12 GA13 GA14 GA15 \
				  GA18 GA19 GA20 GA21 GA23 \
				  GA26 GA27 GA28 GA29 GA30 \
				  GA31 GA32 GA33 GA34 GA35 \
				  GA36 GA37 GA38 GA42 GA44 )
# set temp = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15)
# set temp = (GD11 GD07 GD30 GD02 GD32 GD23 GD01 GD33 GD20 GD44 GD26 GD15)
# set subj_list = `echo $temp | sed "s/D/A/g"`
# outliers : GD29, GD31
# No data : GD19
set root_dir = /Volumes/T7SSD1/GA
set fMRI_dir = $root_dir/fMRI_data
set preproc_dir = /Volumes/clmnlab/GA/fmri_data/preproc_data
set reg_dir = $fMRI_dir/stats/Reg3_{*}
set group_dir = $reg_dir/group

# ========================= make the group directory and move NIFTI data to the directory =========================
if ( ! -d $group_dir ) then
	echo "make the group directory at $reg_dir"
	mkdir -m 777 $group_dir
endif
cd $group_dir
foreach subj ($subj_list)
	## move run1to3.nii.gz to group directory
	set temp = statsRWDtime.$subj.run1to3.SPMG2.nii.gz
	if ( ! -e ./$temp ) then
		echo "move the datum, $temp, to $group_dir"
		mv $reg_dir/$subj/$temp ./
	endif
	## move run4to6.nii.gz to group directory
	set temp = statsRWDtime.$subj.run4to6.SPMG2.nii.gz
	if ( ! -e ./$temp ) then
		echo "move the datum, $temp, to $group_dir"
		mv $reg_dir/$subj/$temp ./
	endif
end

# ========================= make the group full-mask =========================
set temp = ()
foreach subj ($subj_list)
	set temp = ($temp $preproc_dir/$subj/full_mask.$subj+tlrc.HEAD)
end
set gmask = full_mask.GDs
if ( -e $group_dir/$gmask+tlrc.HEAD ) then
	rm $group_dir/$gmask+tlrc.*
endif
3dMean -mask_inter -prefix $group_dir/$gmask $temp

# ========================= 3dttest++ of Reg1 =========================
cd group_dir

## run1to3
set temp = ()
foreach subj ($subj_list)
	set temp = ($temp ./statsRWDtime.$subj.run1to3.SPMG2.nii.gz)
end
set pname = group.1to3
if ( -e $pname+tlrc.HEAD ) then
	rm $pname+tlrc.*
endif
3dttest++ -mask $gmask+tlrc.HEAD -prefix $pname -setA $temp
3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc.

## run4to6
set temp = ()
foreach subj ($subj_list)
	set temp = ($temp ./statsRWDtime.$subj.run4to6.SPMG2.nii.gz)
end
set pname = group.4to6
if ( -e $pname+tlrc.HEAD ) then
	rm $pname+tlrc.*
endif
3dttest++ -mask $gmask+tlrc.HEAD -prefix $pname -setA $temp
3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc.

