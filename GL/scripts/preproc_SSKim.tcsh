#!/bin/tcsh

3dAllineate -base GL03.UnissMPRAGE+tlrc -input pb01.GL03.r02.tshift+orig -1Dmatrix_apply mat.r02.warp.aff12.1D -mast_dxyz 2 -prefix rm.epi.nomask.r02
3dcalc -a pb01.GL03.r01.tshift+orig -expr 1 -prefix rm.epi.all1
3dAllineate -base GL03.UnissMPRAGE+tlrc -input rm.epi.all1+orig -1Dmatrix_apply mat.r01.warp.aff12.1D -mast_dxyz 2 -final NN -quiet -prefix rm.epi.1.r01
3dTstat -min -prefix rm.epi.min.r01 rm.epi.1.r01+tlrc
3dcopy rm.epi.min.r01+tlrc mask_epi_extents
3dcalc -a rm.epi.nomask.r02+tlrc -b mask_epi_extents+tlrc -expr 'a*b' -prefix pb02.GL03.r02.volreg
3dmerge -1blur_fwhm 4 -doall -prefix pb03.GL03.r02.blur pb02.GL03.r02.volreg+tlrc

3dTstat -prefix rm.mean_r02 pb03.GL03.r02.blur+tlrc
3dcalc -a pb01.GL03.r01.tshift+orig -expr 1 -prefix rm.epi.all1
3dAllineate -base GL03.UnissMPRAGE+tlrc -input rm.epi.all1+orig -1Dmatrix_apply mat.r01.warp.aff12.1D -mast_dxyz 2 -final NN -quiet -prefix rm.epi.1.r01
3dTstat -min -prefix rm.epi.min.r01 rm.epi.1.r01+tlrc
3dcopy rm.epi.min.r01+tlrc mask_epi_extents
3dcalc -float -a pb03.GL03.r02.blur+tlrc -b rm.mean_r02+tlrc -c mask_epi_extents+tlrc -expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix pb04.GL03.r02.scale
