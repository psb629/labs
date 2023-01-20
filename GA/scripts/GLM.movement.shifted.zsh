#!/bin/zsh

## ============================================================ ##
## default
time_shift=0
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
		-t | --time_shift)
			## string
			time_shift="$2"
		;;
	esac
	shift ##takes one argument
done
tmp=`printf "%.1f\n" $time_shift`
time_shift=$tmp
stat="${time_shift}s_shifted"
## ============================================================ ##
dir_root="/mnt/ext5/GA"

dir_behav="$dir_root/behav_data"
dir_reg="$dir_behav/regressors/AM/$stat"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj"
## ============================================================ ##
dir_output="$dir_fmri/stats/AM/GLM.movement/$stat/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
cd $dir_output
## 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
3dDeconvolve																			\
	-input "$dir_preproc/pb06.$subj.r0?.scale+tlrc.HEAD"								\
	-censor "$dir_preproc/motion_${subj}_censor.1D"										\
	-mask "$dir_preproc/full_mask.$subj+tlrc.HEAD"										\
    -ortvec $dir_preproc/motion_demean.1D 'motion_demean'								\
	-polort A -float																	\
	-allzero_OK																			\
	-num_stimts 1																		\
	-stim_times_AM2 1 $dir_reg/$subj.movement.txt 'BLOCK(1,1)' -stim_label 1 'Cursor'	\
	-num_glt 1																			\
	-gltsym 'SYM: Cursor' -glt_label 1 'Cursor'											\
	-jobs 1 -fout -tout																	\
	-x1D "X.xmat.$subj.1D" -xjpeg "X.$subj.jpg"											\
	-bucket "stats.Cursor.$subj.nii"

echo " Calculating GLM for subject $subj completed"
