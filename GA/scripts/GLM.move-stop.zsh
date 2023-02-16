#!/bin/zsh

## ============================================================ ##
## default
dir_root="/mnt/ext5/GA"

dir_behav="$dir_root/behav_data"
dir_reg="$dir_behav/regressors/IM/move-stop"

dir_fmri="$dir_root/fmri_data"
## ============================================================ ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-s | --subject)
			## string
			subj="$2"
			dir_preproc="$dir_fmri/preproc_data/$subj/localizer"
		;;
		-GSR | --global_signal_regression)
			case $2 in
				'y' | 'yes')
					GSR=true
					dir_output="$dir_fmri/stats/IM/GLM.move-stop/$subj.GS"
				;;
				*)
					GSR=false
					dir_output="$dir_fmri/stats/IM/GLM.move-stop/$subj"
				;;
			esac
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
cd $dir_output

if [[ $GSR = true ]]; then
	tsmean_GS=$dir_preproc/"$subj.global_signal.whole_brain.1D"
	if [ ! -f $tsmean_GS ];then
		/home/sungbeenpark/Github/labs/GA/scripts/extract.global_signal.zsh -s $subj -p 0
	fi
	3dDeconvolve															\
		-input $dir_preproc/"pb06.$subj.r0?.scale+tlrc.HEAD"				\
		-censor $dir_preproc/"motion_${subj}_censor.1D"						\
		-mask $dir_preproc/"full_mask.$subj+tlrc.HEAD"						\
	    -ortvec $dir_preproc/"motion_demean.1D" 'motion_demean'				\
	    -ortvec $tsmean_GS 'GS'													\
		-polort A -float													\
		-allzero_OK															\
		-num_stimts 2														\
		-stim_times_AM2 1 $dir_reg/"Move.1D" 'dmBLOCK' -stim_label 1 'Move'	\
		-stim_times_AM2 2 $dir_reg/"Stop.1D" 'dmBLOCK' -stim_label 2 'Stop'	\
		-jobs 1 -tout														\
		-x1D "X.xmat.$subj.1D" -xjpeg "X.$subj.jpg"							\
		-bucket "stats.move-stop.$subj.nii"
else
	3dDeconvolve															\
		-input $dir_preproc/"pb06.$subj.r0?.scale+tlrc.HEAD"				\
		-censor $dir_preproc/"motion_${subj}_censor.1D"						\
		-mask $dir_preproc/"full_mask.$subj+tlrc.HEAD"						\
	    -ortvec $dir_preproc/"motion_demean.1D" 'motion_demean'				\
		-polort A -float													\
		-allzero_OK															\
		-num_stimts 2														\
		-stim_times_AM2 1 $dir_reg/"Move.1D" 'dmBLOCK' -stim_label 1 'Move'	\
		-stim_times_AM2 2 $dir_reg/"Stop.1D" 'dmBLOCK' -stim_label 2 'Stop'	\
		-jobs 1 -tout														\
		-x1D "X.xmat.$subj.1D" -xjpeg "X.$subj.jpg"							\
		-bucket "stats.move-stop.$subj.nii"
fi

echo " Calculating GLM for subject $subj completed"
