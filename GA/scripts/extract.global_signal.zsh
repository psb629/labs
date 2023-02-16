#!/bin/zsh

## ============================================================ ##
## default
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
		;;
		-p | --phase)
			case $2 in
				0 | 'localizer')
					phase='localizer'
				;;
				1 | 'prac' | 'practice')
					phase='prac'
				;;
				2 | 'unprac' | 'unpractice')
					phase='unprac'
				;;
				*)
					phase=false
				;;
			esac
		;;
	esac
	shift ##takes one argument
done
if [ $phase = false ]; then
	exit
fi
## ============================================================ ##
dir_root="/mnt/ext5/GA/fmri_data"
dir_mask="$dir_root/masks"
dir_preproc="$dir_root/preproc_data/$subj/$phase"

dir_output=$dir_preproc
## ============================================================ ##
mask="$dir_mask/mask.group.GA.n30.frac=0.7.nii"

cd $dir_output
3dmaskave -quiet -mask $mask $dir_preproc/"pb0?.$subj.r0?.scale+tlrc.HEAD" >$subj.global_signal.whole_brain.1D
