#!/bin/zsh

##############################################################
## default
ROI=false
subj=false
phase=false
radius=3
RGS=false
##############################################################
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-R | --ROI)
			ROI="$2"
		;;
		-s | --subj)
			subj="$2"
		;;
		-p | --phase)
			phase="$2"
		;;
		-r | --radius)
			radius="$2"
		;;
		-G | --RemoveGlobalSignal)
			if [[ ($2 == 'y') || ($2 == 'yes') ]]; then
				RGS=true
			elif [[ ($2 == 'n') || ($2 == 'no') ]]; then
				RGS=false
			fi
		;;
	esac
	shift ##takes one argument
done
if [ $ROI = false ]; then
	exit
elif [ $subj = false ]; then
	exit
elif [ $phase = false ]; then
	exit
fi
##############################################################
dir_root="/mnt/ext5/SMC/fmri_data"
dir_preproc="$dir_root/preproc_data/$phase.anaticor/with_FreeSurfer/$subj"
dir_mask="$dir_root/masks"

dir_output="$dir_root/stats/correlations/$ROI"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
##############################################################
## how to deal with Global Signal
fname="$dir_preproc/errts.$subj.fanaticor+tlrc"
if [[ $RGS = true ]]; then
	## use 3dTproject to project out GS(global signal) which make errts like 3dDeconvolve, but more quickly.
	pname="$dir_preproc/errts.$subj.fanaticor.GlobalSignalRemoved.nii"
	3dTproject												\
		-polort 0											\
		-input $fname										\
		-mask "$dir_preproc/full_mask.$subj+tlrc"			\
		-censor "$dir_preproc/censor_${subj}_combined_2.1D"	\
		-cenmode ZERO										\
		-ort "$dir_preproc/mean.errts.1D"					\
		-prefix $pname
	fname=$pname
fi
tmp=`3dinfo "$fname" | grep "Number of time steps"`
timestep=`printf "%d" $tmp[24,26]`
##############################################################
output="$dir_output/3dmaskave.$ROI.$subj.$phase.GlobalSignalRemoved=$RGS.t$timestep.1D"
## calculate the average BOLD response in the ROI
3dmaskave											\
	-quiet											\
	-mask "$dir_mask/3dUndump.$ROI.r=$radius.nii"	\
	$fname > $output

## calculate the whole-brain correlation
3dTcorr1D																			\
	-prefix "$dir_output/3dTcorr1D.$ROI.$subj.$phase.GlobalSignalRemoved=$RGS.nii"	\
	-mask "$dir_mask/mask.group.n56.frac=0.7.nii"									\
	$fname $output
