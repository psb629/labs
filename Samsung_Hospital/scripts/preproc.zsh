#!/bin/zsh

## initialize arguments
name="noname"
only_convert=false
decided_output_dir=false
do_scale=false

## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-n | --name)
			name="$2"
		;;
		-d | --data_dir)
			data_dir="$2"
		;;
		-o | --output_dir)
			output_dir="$2"
			decided_output_dir=true
		;;
		-only_convert)
			only_convert=true
		;;
		-s | --scale)
			if [[ ($2 == 'y') || ($2 == 'yes') ]]; then
				do_scale=true
			fi
		;;
	esac
	shift ##takes one argument
done

## make the output directory
if [[ $decided_output_dir = false ]]; then
	output_dir=$data_dir/preprocessed
fi
mkdir -p -m 755 $output_dir

dcm2niix_afni -o $output_dir -s y -z n -f "tmp" $data_dir
if [[ $do_scale = true ]]; then
	3dcalc -a $output_dir/tmp.nii -expr "a*0.01" -prefix $output_dir/${name}_T1.nii
else
	3dcalc -a $output_dir/tmp.nii -expr "a" -prefix $output_dir/${name}_T1.nii
fi
rm $output_dir/tmp.*

if [[ $only_convert = false ]]; then
	########
	# ANAT # : 3dWarp -> 3dresample -> 3dUnifize -> 3dSkullStrip -> @auto_tlrc
	########
	cd $output_dir
	
	3dcopy ${name}_T1.nii $name.anat+orig
	 #3dWarp -deoblique -prefix $name.anat.deoblique $name.anat+orig > deoblique.$name.aff.2D
	
	# ================ change the orientation of a dataset ================
	## 'LPI' means an one of the 'neurcoscience' orientation, where the x-axis is Left-to-Right, the y-axis is Posterior-to-Anterior, and the z-axis is Inferior-to-Superior:
	3dresample -orient LPI -prefix $name.anat.lpi -input $name.anat+orig
	# ================================= skull-striping =================================
	## unifize -> ss : S23 has a problem with cutting brain
	3dSkullStrip -input $name.anat.lpi+orig -prefix $name.anat.ss -orig_vol
	# ================================= unifize =================================
	## In case of Na, it needs to unifize first.
	3dUnifize -input $name.anat.ss+orig -prefix $name.anat.unifize -GM -clfrac 0.5
	
	# ================================= tlrc coordinate ==================================
	cd $output_dir
	## warp anatomy to standard space, input dataset must be in the current directory:
	@auto_tlrc -base /usr/local/afni/abin/MNI152_T1_2009c+tlrc.HEAD -input $name.anat.unifize+orig -no_ss -init_xform AUTO_CENTER
	## find attribute WARP_DATA in dataset; -I, invert the transformation:
	cat_matvec $name.anat.unifize+tlrc::WARP_DATA -I > warp.$name.anat.Xat.1D
fi
