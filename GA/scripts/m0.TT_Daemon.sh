#!/bin/tcsh

set root_dir = /Volumes/T7SSD1/GA
set fmri_dir = $root_dir/fMRI_data
set roi_dir = $fmri_dir/roi
set output_dir = $roi_dir/TT_Daemon
# =========================================================
set TT_Daemon = ~/abin/TTatlas+tlrc
set TT_resem = $output_dir/TTatlas.resem.nii.gz
if (! -d $output_dir) then
	mkdir -p -m 755 $output_dir
endif
 #set master = $roi_dir/full_mask.GAs.nii.gz
 #3dresample -master $master -prefix $TT_resem -input $TT_Daemon
# =========================================================
### sub-brick #
set uu3 = 0
set uu5 = 1
set uu = $uu5
# =========================================================
## voxel values from uu3 (right left region)
# =========================================================
## voxel values from uu5 (right left region)
 #set vv_list = (94 294 BA17)
 #set vv_list = (95 295 BA18)
 #set vv_list = (96 296 BA19)
 #set vv_list = (97 297 BA20)
 #set vv_list = (113 313 BA37)
 #set vv_list = (114 314 BA38)
# =========================================================
set vv1 = $vv_list[1]
set vv2 = $vv_list[2]

 #set pname = $output_dir/TT_Daemon.brik$uu.${vv_list[3]}
 #3dcalc -a "${TT_resem}[$uu]" -expr "iszero(a-$vv1)+iszero(a-$vv2)" -prefix $pname
 ### count the number of non-zero voxels
 #set nn = `3dBrickStat -count -non-zero $pname+tlrc`
 #3dAFNItoNIFTI -prefix $pname.n$nn.nii.gz $pname+tlrc
 #rm $pname+tlrc.*
# =========================================================
## right-side
set pname = $output_dir/TT_Daemon.brik$uu.${vv_list[3]}R
3dcalc -a "${TT_resem}[$uu]" -expr "iszero(a-$vv1)" -prefix $pname
set nn = `3dBrickStat -count -non-zero $pname+tlrc`
3dAFNItoNIFTI -prefix $pname.n$nn.nii.gz $pname+tlrc
rm $pname+tlrc.*
# =========================================================
## left_side
set pname = $output_dir/TT_Daemon.brik$uu.${vv_list[3]}L
3dcalc -a "${TT_resem}[$uu]" -expr "iszero(a-$vv2)" -prefix $pname
set nn = `3dBrickStat -count -non-zero $pname+tlrc`
3dAFNItoNIFTI -prefix $pname.n$nn.nii.gz $pname+tlrc
rm $pname+tlrc.*
