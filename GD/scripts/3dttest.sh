#!/bin/tcsh

set subj_list = (GD11 GD07 GD30 GD02 GD29 GD32 GD23 GD01 GD31 GD33 GD20 GD44 GD26 GD15 GD38)
# outliers : GD29, GD31
# No data : GD19
set root_dir = /Volumes/T7SSD1/GD
set fMRI_dir = $root_dir/fMRI_data
set preproc_dir = $fMRI_dir/preproc_data
set reg_dir = $fMRI_dir/stats/Reg1_{*}
#set reg_dir = $fMRI_dir/stats/Reg2_{*}
set group_dir = $reg_dir/group
set output_dir = $group_dir

# ========================= make the group directory and move NIFTI data to the directory =========================
if ( ! -d $group_dir ) then
	echo "make the group directory at $reg_dir"
	mkdir -p -m 755 $group_dir
endif
foreach subj ($subj_list)
	## make run1to3.nii.gz to group directory
	set from = $reg_dir/$subj/statsRWDtime.$subj.run1to3.SPMG2+tlrc
	set to = $output_dir/statsRWDtime.$subj.run1to3.SPMG2.nii.gz
	if ( ! -e $from ) then
		3dAFNItoNIFTI -prefix $to $from
	endif
	## make run4to6.nii.gz to group directory
	set from = $reg_dir/$subj/statsRWDtime.$subj.run4to6.SPMG2+tlrc
	set to = $output_dir/statsRWDtime.$subj.run4to6.SPMG2.nii.gz
	if ( ! -e $from ) then
		3dAFNItoNIFTI -prefix $to $from
	endif
end

# ========================= make the group full-mask =========================
set temp = ()
foreach subj ($subj_list)
	set temp = ($temp $preproc_dir/$subj/preprocessed/full_mask.$subj+tlrc.HEAD)
end
set gmask = $output_dir/full_mask.GDs.n$#subj_list
if ( -e $gmask+tlrc.HEAD ) then
	rm $gmask+tlrc.* $gmask.nii.gz
endif
3dMean -mask_inter -prefix $gmask $temp
3dAFNItoNIFTI -prefix $gmask.nii.gz $gmask+tlrc.
rm $gmask+tlrc.*

# ========================= 3dttest++ of Reg1 =========================
## run1to3
set temp = ()
foreach subj ($subj_list)
	set temp = ($temp $output_dir/statsRWDtime.$subj.run1to3.SPMG2.nii.gz)
end
set pname = $output_dir/group.1to3
if ( -e $pname+tlrc.HEAD ) then
	rm $pname+tlrc.*
endif
3dttest++ -mask $gmask.nii.gz -prefix $pname -setA $temp
3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc.
rm $pname+tlrc.*

## run4to6
set temp = ()
foreach subj ($subj_list)
	set temp = ($temp $output_dir/statsRWDtime.$subj.run4to6.SPMG2.nii.gz)
end
set pname = $output_dir/group.4to6
if ( -e $pname+tlrc.HEAD ) then
	rm $pname+tlrc.*
endif
3dttest++ -mask $gmask.nii.gz -prefix $pname -setA $temp
3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc.
rm $pname+tlrc.*

#3dttest++ -prefix statsRWDtime.groupA-B.run1to3.SPMG2 -mask /Volumes/clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30+tlrc.HEAD -setA statsRWDtime.GA02.run1to3.SPMG2.nii.gz statsRWDtime.GA07.run1to3.SPMG2.nii.gz statsRWDtime.GA11.run1to3.SPMG2.nii.gz statsRWDtime.GA30.run1to3.SPMG2.nii.gz -Clustsim

 #3dttest++ -prefix statsRWDtime.groupA-B.run1to3.SPMG2 -mask /Volumes/clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30+tlrc.HEAD -setA statsRWDtime.GA01.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA02.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA05.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GA07.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA08.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA11.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA12.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA13.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA14.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA15.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GA18.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA19.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA20.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA21.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA23.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA26.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA27.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GA28.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA29.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA30.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA31.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA32.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA33.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA34.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GA35.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA36.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA37.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA38.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA42.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GA44.run1to3.SPMG2+tlrc.HEAD -setB statsRWDtime.GB01.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GB02.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB05.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB07.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB08.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB11.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB12.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB13.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GB14.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB15.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB18.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB19.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB20.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB21.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB23.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GB26.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB27.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB28.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB29.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB30.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB31.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB32.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GB33.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB34.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB35.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB36.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB37.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB38.run1to3.SPMG2+tlrc.HEAD statsRWDtime.GB42.run1to3.SPMG2+tlrc.HEAD
 #statsRWDtime.GB44.run1to3.SPMG2+tlrc.HEAD -paired -Clustsim
 #
 #3drefit -atrstring AFNI_CLUSTSIM_NN1_1sided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN1_1sided.niml -atrstring AFNI_CLUSTSIM_NN2_1sided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN2_1sided.niml
 #-atrstring AFNI_CLUSTSIM_NN3_1sided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN3_1sided.niml -atrstring AFNI_CLUSTSIM_NN1_2sided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN1_2sided.niml -atrstring AFNI_CLUSTSIM_NN2_2sided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN2_2sided.niml
 #-atrstring AFNI_CLUSTSIM_NN3_2sided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN3_2sided.niml -atrstring AFNI_CLUSTSIM_NN1_bisided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN1_bisided.niml -atrstring AFNI_CLUSTSIM_NN2_bisided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN2_bisided.niml
 #-atrstring AFNI_CLUSTSIM_NN3_bisided file:statsRWDtime.groupA-B.run1to3.SPMG2.CSimA.NN3_bisided.niml ./statsRWDtime.groupA-B.run1to3.SPMG2+tlrc.HEAD
