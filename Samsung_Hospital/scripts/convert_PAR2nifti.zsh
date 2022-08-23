#!/bin/zsh

dir_root="/mnt/ext7/SMC/fmri_data"
dir_raw="$dir_root/raw_data"
dir_preproc="$dir_root/preproc_data"

subj='S25'
dir_output=$dir_preproc/$subj
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi

cd $dir_output
foreach image ('T1' 'FMRI')
	dcm2niix_afni -o $dir_output -s y -f "${subj}_${image}" $dir_raw/${subj}*/${subj}_*_${image}.PAR
end
mv ${subj}_FMRI.json ${subj}_FMRI_t0000.json
mv ${subj}_FMRI.nii ${subj}_FMRI_t0000.nii

foreach t (`seq -f "%04g" 0 2000 598000`)
	t_new=`printf %06d $t`
	mv ${subj}_FMRI_t$t.nii tmp_t$t_new.nii
end
3dTcat -tr 2 -prefix $dir_output/${subj}_func.nii $dir_output/tmp_t*.nii

rm $dir_output/tmp*.nii $dir_output/*.json
