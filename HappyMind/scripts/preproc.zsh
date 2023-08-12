#!/bin/zsh

## ====================================================== ##
## initialize arguments
subj="Anonymous"
## ====================================================== ##
while (( $# )); do
	key="$1"
	case $key in
		-s | --subject)
			subj="$2"
		;;
		-r | --dir_raw)
			dir_raw="$2"
		;;
		-h |--help)
			echo "-s, --subject:"
			echo "\tSubject name (default='Anonymous')"
			echo "-r, --dir_raw:"
			echo "\tThe location of the raw data directory"
			exit
		;;
	esac
	shift ##takes one argument
done
## ====================================================== ##
## make the output directory
dir_output=$dir_raw/preprocessed
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ====================================================== ##
dcm2niix_afni -o $dir_output -s y -z n -f "$subj.T1" $dir_raw
## ====================================================== ##
########
# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
########
cd $dir_output

3dcopy $subj.T1.nii $subj.anat+orig
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
## warp anatomy to standard space, input dataset must be in the current directory:
@auto_tlrc -base /usr/local/afni/abin/MNI152_T1_2009c+tlrc.HEAD -input $subj.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
## find attribute WARP_DATA in dataset; -I, invert the transformation:
cat_matvec $subj.anat.unifize+tlrc::WARP_DATA -I > warp.$subj.anat.Xat.1D
## ====================================================== ##
## Affine transformation
dir_work="$HOME/Github/labs/HappyMind/scripts"
ii=0
for xyz in '-41 43 27' '-50 -67 33'
{
	if [[ $ii == 0 ]]; then
		print " Depression ($xyz)"
	elif [[ $ii == 1 ]]; then
		print " Dementia ($xyz)"
	fi
	$dir_work/affine_transformator.py -s $subj -d $dir_output -m 'mni' -o 'lpi' --xyz $xyz
	(( ii = $ii + 1 ))
}
