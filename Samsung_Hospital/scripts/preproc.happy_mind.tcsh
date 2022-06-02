#!/bin/tcsh

set dir_root = ~/Happy_Mind

set subj = "Jungmin_Lee"
set dir_output = ~/Happy_Mind/preproc_data/$subj
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif

dcm2niix_afni -o $dir_output -s y -z n -f "tmp" $dir_root/$subj
## the original data has too high intensity.
3dcalc -a $dir_output/tmp.nii -expr "a*0.01" -prefix $dir_output/${subj}_T1.nii
rm $dir_output/tmp.*
#########################################################
########
# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
########
cd $dir_output

3dcopy ${subj}_T1.nii $subj.anat+orig
 #3dWarp -deoblique -prefix $subj.anat.deoblique $subj.anat+orig > deoblique.$subj.aff.2D

# ================ change the orientation of a dataset ================
## 'LPI' means an one of the 'neurcoscience' orientation, where the x-axis is Left-to-Right, the y-axis is Posterior-to-Anterior, and the z-axis is Inferior-to-Superior:
3dresample -orient LPI -prefix $subj.anat.lpi -input $subj.anat+orig
# ================================= skull-striping =================================
## unifize -> ss : S23 has a problem with cutting brain
3dSkullStrip -input $subj.anat.lpi+orig -prefix $subj.anat.ss -orig_vol
# ================================= unifize =================================
## In case of Na, it needs to unifize first.
3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5

# ================================= tlrc coordinate ==================================
cd $dir_output
## warp anatomy to standard space, input dataset must be in the current directory:
@auto_tlrc -base /usr/local/afni/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
## find attribute WARP_DATA in dataset; -I, invert the transformation:
cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D
