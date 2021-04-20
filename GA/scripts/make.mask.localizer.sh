#!/bin/zsh

root_dir=/Volumes/T7SSD1/GA
fmri_dir=$root_dir/fMRI_data
stats_dir=$fmri_dir/stats
data_dir=$stats_dir/GLM.move-stop

output_dir=$data_dir

key_list=(L_Postcentral R_CerebellumIV-V R_Postcentral L_Putamen S_SMA R_CerebellumVIIIb L_Thalamus)

foreach nn (`count -digits 4 1 7`)
	## count the number of non-zero voxels
	n_voxels=`3dBrickStat -count -non-zero $data_dir/Clust_mask_${nn}+tlrc`
	3dAFNItoNIFTI -prefix $output_dir/n$[$n_voxels+0].$key_list[$nn].nii.gz $data_dir/Clust_mask_${nn}+tlrc
end
