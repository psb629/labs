#!/bin/zsh

dir_root=/mnt/sdb2/GL/fmri_data
dir_preproc=$dir_root/preproc_data

dir_output=$dir_root/masks
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi

coord='tlrc'
tmp=(`ls $dir_preproc/GL??/$coord/full_mask.GL??+$coord.HEAD`)
# ========================= make the group full-mask =========================
3dMean -mask_inter -prefix $dir_output/full_mask.GL+$coord.nii $tmp
