#!/bin/zsh

root_dir=/Volumes/T7SSD1/GA
fmri_dir=$root_dir/fMRI_data
roi_dir=$fmri_dir/roi
stats_dir=$fmri_dir/stats
data_dir=$stats_dir/GLM.move-stop

output_dir=$roi_dir/localizer_sampark
if [ ! -d $output_dir ]; then
	mkdir -m p 755 $output_dir
fi

key_list=(L_Postcentral R_CerebellumIV-V R_Postcentral L_Putamen S_SMA R_CerebellumVIIIb L_Thalamus)

foreach nn (`count -digits 4 1 7`)
	## count the number of non-zero voxels
	n_voxels=$[`3dBrickStat -count -non-zero $data_dir/Clust_mask_${nn}+tlrc`+0]
	## make sure the values in the clusters are all-1
	3dcalc -a "$data_dir/Clust_mask_${nn}+tlrc" -expr 'ispositive(a)' -prefix $output_dir/temp.$nn
	3dAFNItoNIFTI -prefix $output_dir/n$n_voxels.$key_list[$nn].nii.gz $output_dir/temp.$nn+tlrc
	rm $output_dir/temp.????+tlrc.*
end
