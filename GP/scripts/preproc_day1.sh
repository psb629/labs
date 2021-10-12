#!/bin/tcsh

#=============================================
set res = 2.683
set fwhm = 4
set thresh_motion = 0.4
#=============================================
set list_subj = ( GP08 GP09 GP10 GP11 GP17 GP18 GP20 GP21 )
#=============================================
set root_dir = $HOME/Desktop/GP
#=============================================
foreach subj ($list_subj)
	set tmp = $root_dir/$subj/day1
	set raw_dir = $tmp/`ls $tmp`
	set output_dir = $root_dir/preprocessed/$subj
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
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/$subj.MPRAGE $output_dir/temp+orig
	rm $output_dir/temp*
	
	# ==================================================================
	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########
	
	cd $output_dir
	## Will copy only the dataset with the given view (orig, acpc, tlrc).
	# ================================= skull-striping =================================
	3dSkullStrip -input $subj.MPRAGE+orig -prefix $subj.anat.ss -orig_vol
	# ================================= unifize =================================
	## this program can be a useful step to take BEFORE 3dSkullStrip, since the latter program can fail if the input volume is strongly shaded -- 3dUnifize will (mostly) remove such shading artifacts.
	3dUnifize -input $subj.anat.ss+orig -prefix $subj.anat.unifize -GM -clfrac 0.5
	# ================================== tlrc ==================================
	## warp anatomy to standard space, input dataset must be in the current directory:
	cd $output_dir
	@auto_tlrc -base ~/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
	## find attribute WARP_DATA in dataset; -I, invert the transformation:
	## cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D ## == $subj.anat.unifize.Xat.1D
	3dAFNItoNIFTI -prefix anat_final.$subj.nii $subj.anat.unifize+tlrc
	
	# ==================================================================
	echo "subject $subj completed!"
end
