#!/bin/tcsh

set subj = "Na"
set coord = tlrc

set dir_root = ~/Downloads/Na_220102
set t1 = $dir_root/${subj}_T1.nii
#########################################################
set dir_output = $dir_root/preprocessed
if ( ! -d $dir_output ) then
	mkdir -p -m 755 $dir_output
endif
########
# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
########
cd $dir_output

3dcopy $t1 $subj.anat+orig
 #3dWarp -deoblique -prefix $subj.anat.deoblique $subj.anat+orig > deoblique.$subj.aff.2D

# ================ change the orientation of a dataset ================
## 'LPI' means an one of the 'neurcoscience' orientation, where the x-axis is Left-to-Right, the y-axis is Posterior-to-Anterior, and the z-axis is Inferior-to-Superior:
 #3dresample -orient LPI -prefix $subj.anat.lpi -input $subj.anat.deoblique+orig
3dresample -orient LPI -prefix $subj.anat.lpi -input $subj.anat+orig

# ================================= skull-striping =================================
## unifize -> ss : S23 has a problem with cutting brain
3dSkullStrip -input $subj.anat.lpi+orig -prefix $subj.anat.ss -orig_vol
# ================================= unifize =================================
## this program can be a useful step to take BEFORE 3dSkullStrip, since the latter program can fail if the input volume is strongly shaded -- 3dUnifize will (mostly) remove such shading artifacts.
3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5

cd $dir_output
# ================================= tlrc coordinate ==================================
if ($coord == tlrc) then
	## warp anatomy to standard space, input dataset must be in the current directory:
	@auto_tlrc -base ~/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
	## find attribute WARP_DATA in dataset; -I, invert the transformation:
	cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D
	3dAFNItoNIFTI -prefix anat_final.$subj.nii.gz $subj.anat.unifize+tlrc
endif

