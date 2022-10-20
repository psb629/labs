#!/bin/tcsh

#=============================================
set res = 2.683
set fwhm = 4
set thresh_motion = 0.4
#=============================================
set list_nn=( 08 09 10 11 17 18 19 20 21 22 \
			  24 26 27 32 33 34 35 36 37 38 \
			  39 40 41 42 43 44 45 46 47 48 \
			  49 50 51 53 54 55 )
set list_nn=( 36 37 38 \
			  39 40 41 42 43 )
#=============================================
set root_dir = /mnt/ext7/GP/fmri_data
#=============================================
foreach nn ($list_nn)
	set subj = "GP$nn"

 #	set raw_dir = $root_dir/raw_data/$subj/day1
	set raw_dir = /mnt/ext4/GP/fmri_data/raw_data/$subj/day1
	set preproc_dir = $root_dir/preproc_data/$subj/day1
	set output_dir = $preproc_dir/preprocessed
	if ( ! -d $output_dir ) then
		mkdir -p -m 755 $output_dir
	endif
	#=============================================
	## rename folders
	set T1 = $raw_dir/T1
	cd $raw_dir
	if ( ! -d $T1 ) then
		mv ./T1_MPRAGE_SAG_1_0ISO_00?? $T1
	endif
	#=============================================
	## Convert *.IMA files to *.BRIK/*.HEAD
	cd $T1
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $preproc_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $preproc_dir/$subj.MPRAGE $preproc_dir/temp+orig
	rm $preproc_dir/temp*
	
	# ==================================================================
	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########
	
	cd $output_dir
	## Will copy only the dataset with the given view (orig, acpc, tlrc).
	# ================================= skull-striping =================================
	3dSkullStrip -input $preproc_dir/$subj.MPRAGE+orig -prefix $subj.anat.ss -orig_vol
	# ================================= unifize =================================
	## this program can be a useful step to take BEFORE 3dSkullStrip, since the latter program can fail if the input volume is strongly shaded -- 3dUnifize will (mostly) remove such shading artifacts.
	3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5
	# ================================== tlrc ==================================
	## warp anatomy to standard space, input dataset must be in the current directory:
	cd $output_dir
	@auto_tlrc -base /usr/local/afni/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
	## find attribute WARP_DATA in dataset; -I, invert the transformation:
	## cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D ## == $subj.anat.unifize.Xat.1D
	3dAFNItoNIFTI -prefix anat_final.$subj.nii $subj.anat.unifize+tlrc
	
	# ==================================================================
	echo "subject $subj completed!"
end
