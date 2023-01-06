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
## ============================================================ ##
dir_output="$dir_fmri/stats/GLM.Move-Stop/$subj"
 #dir_output="/mnt/sda2/GP/fmri_data/stats/GLM.Move-Stop/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
cd $dir_output
3dDeconvolve -input "$dir_preproc/pb04.$subj.localizer.scale+tlrc"									\
	-mask "$dir_preproc/full_mask.$subj+tlrc"														\
	-censor "$dir_preproc/motion_${subj}_censor.1D"													\
	-polort A -float -local_times																	\
	-num_stimts 8																					\
	-num_glt 1																						\
	-stim_times_AM1 1 "$dir_reg/$subj.Move.1D" dmBLOCK -stim_label 1 Move							\
	-stim_times_AM1 2 "$dir_reg/$subj.Stop.1D" dmBLOCK -stim_label 2 Stop							\
	-stim_file 3 "$dir_preproc/motion_demean.$subj.localizer.1D[0]" -stim_base 3 -stim_label 3 roll	\
	-stim_file 4 "$dir_preproc/motion_demean.$subj.localizer.1D[1]" -stim_base 4 -stim_label 4 pitch\
	-stim_file 5 "$dir_preproc/motion_demean.$subj.localizer.1D[2]" -stim_base 5 -stim_label 5 yaw	\
	-stim_file 6 "$dir_preproc/motion_demean.$subj.localizer.1D[3]" -stim_base 6 -stim_label 6 dS	\
	-stim_file 7 "$dir_preproc/motion_demean.$subj.localizer.1D[4]" -stim_base 7 -stim_label 7 dL	\
	-stim_file 8 "$dir_preproc/motion_demean.$subj.localizer.1D[5]" -stim_base 8 -stim_label 8 dP	\
	-gltsym 'SYM: Move -Stop' -glt_label 1 Move-Stop												\
	-jobs 1																							\
	-fout -tout																						\
	-x1D X.stat.move-stop.xmat.1D -xjpeg X.stat.move-stop.jpg										\
	-x1D_uncensored X.stat.move-stop.nocensor.xmat.1D												\
	-bucket $subj.stat.move-stop
