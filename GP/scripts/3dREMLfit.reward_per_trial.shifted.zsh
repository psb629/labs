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
## ============================================================ ##
dir_root="/mnt/ext5/GP"
stat="${time_shift}s_shifted"

dir_behav="$dir_root/behav_data"
dir_reg="$dir_behav/regressors/AM/$stat"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj/day2"
dir_stat="$dir_fmri/stats/AM"
dir_xmat="$dir_stat/GLM.reward_per_trial/$stat/$subj"
## ============================================================ ##
dir_output="$dir_stat/3dREMLfit.reward_per_trial/$stat/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
cd $dir_output
3dREMLfit													\
	-matrix "$dir_xmat/X.xmat.$subj.1D"						\
	-input "$dir_preproc/pb06.$subj.r0?.scale+tlrc.HEAD"	\
	-mask "$dir_preproc/full_mask.$subj+tlrc.HEAD"			\
	-Rvar "varR.Rew.$subj.nii"								\
	-Rbuck "funcR.Rew.$subj.nii"							\
	-Rfitts "fittsR.Rew.$subj.nii"							\
	-Obuck "funcO.Rew.$subj.nii"							\
	-Ofitts "fittsO.Rew.$subj.nii"							\
	-Rglt "Colstats.Rew.$subj.nii" -gltsym 'SYM: Col[16]'	\
	-fout -tout

echo " Calculating GLM for subject $subj completed"
