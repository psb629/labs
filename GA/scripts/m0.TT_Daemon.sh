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
## voxel values
set vv1 = 94 # BA17_Right
set vv2 = 294 # BA17_Left

set pname = $output_dir/TT_Daemon.$vv1+$vv2
3dcalc -a "${TT_Daemon}[1]" -expr "iszero(a-$vv1)+iszero(a-$vv2)" -prefix $pname
## count the number of non-zero voxels
set nn = `3dBrickStat -count -non-zero $pname+tlrc`
3dAFNItoNIFTI -prefix $pname.n$nn.nii.gz $pname+tlrc
rm $pname+tlrc.*
