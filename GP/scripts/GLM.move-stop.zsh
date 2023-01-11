#!/bin/zsh

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
	esac
	shift ##takes one argument
done
## ============================================================ ##
dir_root="/mnt/ext5/GP"

dir_behav="$dir_root/behav_data"
dir_reg="$dir_behav/regressors/move-stop"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj/day1"
dir_stat="$dir_fmri/stats/GLM.move-stop/$subj"
## ============================================================ ##
dir_output=$dir_stat
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
cd $dir_output
3dDeconvolve -input "$dir_preproc/pb04.$subj.localizer.scale+tlrc"				\
	-censor "$dir_preproc/motion_${subj}_censor.1D"								\
	-mask "$dir_preproc/full_mask.$subj+tlrc.HEAD"								\
    -ortvec "$dir_preproc/motion_demean.$subj.localizer.1D" 'motion_demean'		\
	-polort A -float -local_times												\
	-num_stimts 2																\
	-stim_times_AM1 1 "$dir_reg/$subj.Move.1D" dmBLOCK -stim_label 1 Move		\
	-stim_times_AM1 2 "$dir_reg/$subj.Stop.1D" dmBLOCK -stim_label 2 Stop		\
	-num_glt 1																	\
	-gltsym 'SYM: Move -Stop' -glt_label 1 Move-Stop							\
	-jobs 1																		\
	-fout -tout																	\
	-x1D X.xmat.$subj.1D -xjpeg X.$subj.jpg										\
	-x1D_uncensored X.xmat.nocensor.$subj.1D									\
	-bucket stat.move-stop.$subj.nii
