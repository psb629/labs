#!/bin/tcsh

3dcopy /Volumes/clmnlab/GA/fmri_data/GA_caudate_ROI/slicer_2/GA01_1_caudate_head.nii.gz GA01_1_caudate_heada
3dresample -master /clmnlab/GA/fmri_data/preproc_data/GA01/GA01.UnisSanat+orig \
		   -prefix /clmnlab/GA/fmri_data/GA_caudate_ROI/slicer_2/resam_into_orig/GA01_1_caudate_head_orig \
		   -input /clmnlab/GA/fmri_data/GA_caudate_ROI/slicer_2/raw/GA01_1_caudate_head+orig
3dAllineate -base /clmnlab/GA/fmri_data/preproc_data/GA01/GA01.UnisSanat+orig \
			-source /clmnlab/GA/fmri_data/GA_caudate_ROI/slicer_2/resam_into_orig/GA01_1_caudate_head_orig+orig \
			-master /clmnlab/GA/fmri_data/preproc_data/GA01/full_mask.GA01+tlrc \
			-final NN \
			-1Dmatrix_apply /clmnlab/GA/fmri_data/preproc_data/GA01/warp.anat.Xat.1D \
			-prefix /clmnlab/GA/fmri_data/GA_caudate_ROI/slicer_2/tlrc_resam_fullmask/GA01_1_caudate_head_resam
