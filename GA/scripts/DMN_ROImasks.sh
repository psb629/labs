#20190905 JISULEE

# master: whose geometry will determine the geometry of the output.

set master_path = /clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data/
set roi_path = /clmnlab/GA/fmri_data/masks/DMN/


set roi_names = (Core_aMPFC_l Core_aMPFC_r Core_PCC_l Core_PCC_r dMsub_dMPFC dMsub_LTC_l  \
dMsub_LTC_r dMsub_TempP_l dMsub_TempP_r dMsub_TPJ_l dMsub_TPJ_r MTLsub_HF_l MTLsub_HF_r \
MTLsub_PHC_l MTLsub_PHC_r MTLsub_pIPL_l MTLsub_pIPL_r MTLsub_Rsp_l MTLsub_Rsp_r MTLsub_vMPFC)

cd $roi_path
foreach name ($roi_names)

3dUndump -prefix $name -master $master_path/betasLSS.MO.shortdur.GA01.r01+tlrc. -mask /clmnlab/GA/MVPA/fullmask_GAGB/full_mask_GAGB_n30.nii.gz  \
-srad 10 -xyz "${name}.1D";
3dAFNItoNIFTI -prefix $name $name+tlrc

end
