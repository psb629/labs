#!/bin/tcsh

set ii_list = ( GA GB )
set nn_list = ( 01 02 05 07 08 \
				11 12 13 14 15 \
				18 19 20 21 23 \
				26 27 28 29 30 \
				31 32 33 34 35 \
				36 37 38 42 44 )
# set subj_list = `echo $temp | sed "s/D/A/g"`
set root_dir = /Volumes/T7SSD1/WinterCamp2021
set fmask_dir = $root_dir/masks/full
set search_dir = $root_dir/searchlight
set output_dir = $search_dir
# ========================= make the group full-mask =========================
set temp = ()
foreach nn ($nn_list)
	set temp = ($temp $fmask_dir/full_mask.GA$nn.nii.gz)
end
set gmask = $output_dir/full_mask.GAs.nii.gz
if ( -e $gmask ) then
	rm $gmask
endif
3dMean -mask_inter -prefix $gmask $temp
# ========================= 3dttest++ of Reg1 =========================
## run1to3
set temp = ()
foreach ii ($ii_list)
	foreach nn ($nn_list)
		set subj = $ii$nn
		set temp = ($temp $search_dir/1to3/${subj}_r6_lda_pos.nii.gz)
	end
	set pname = $output_dir/group.$ii.1to3.nii.gz
	if ( -e $pname ) then
		rm $pname
	endif
	3dttest++ -mask $gmask -prefix $pname -setA $temp
end
## paired t-test
set GAs = ()
set GBs = ()
foreach nn ($nn_list)
	set GAs = ($GAs $search_dir/1to3/GA${nn}_r6_lda_pos.nii.gz)
	set GBs = ($GBs $search_dir/1to3/GB${nn}_r6_lda_pos.nii.gz)
end
set pname = $output_dir/group.GB-GA.1to3.nii.gz
if ( -e $pname ) then
rm $pname
endif
3dttest++ -paired -mask $gmask -prefix $pname -setA $GAs -setB $GBs
## run4to6
 #set temp = ()
 #foreach subj ($subj_list)
 #	set temp = ($temp ./statsRWDtime.$subj.run4to6.SPMG2.nii.gz)
 #end
 #set pname = group.4to6
 #if ( -e $pname+tlrc.HEAD ) then
 #	rm $pname+tlrc.*
 #endif
 #3dttest++ -mask $gmask+tlrc.HEAD -prefix $pname -setA $temp
 #3dAFNItoNIFTI -prefix $pname.nii.gz $pname+tlrc.

