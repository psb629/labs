#20191115 EYS

# master: whose geometry will determine the geometry of the output.

set master_path = /Volumes/clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data/
set roi_path = /Volumes/clmnlab/GA/fmri_data/masks/DMN/


set roi_names = ("dMsub_TempP_l" "dMsub_TempP_r")

cd $roi_path
foreach name ($roi_names)

    3dUndump -prefix "temp" \
        -master $master_path/betasLSS.MO.shortdur.GA01.r01+tlrc.HEAD \
        -srad 10 -xyz "${name}.1D";

    3dcalc -a "temp+tlrc.HEAD" \
        -b /Volumes/clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30.nii.gz \
        -expr "a*b" \
        -prefix ${name}_"temp"

    3dAFNItoNIFTI -prefix $name"_temp" $name"_temp"+tlrc

    rm temp+tlrc.*

end
