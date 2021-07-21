#20190905 JISULEE

# master: whose geometry will determine the geometry of the output.

set master_path = /clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data/
set roi_path = /clmnlab/GA/fmri_data/masks/DMN/


set roi_names = (Average)

cd $roi_path
foreach name ($roi_names)

3dUndump -prefix $name -master $master_path/betasLSS.MO.shortdur.GA01.r01+tlrc. -mask /clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30.nii.gz  \
-srad 10 -xyz "${name}.1D";
3dAFNItoNIFTI -prefix $name $name+tlrc

end
