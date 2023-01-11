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
dir_reg="$dir_behav/regressors/AM"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj/day2"
## ============================================================ ##
dir_output="$dir_fmri/stats/AM/GLM.reward_per_1s/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
## convert motion_demean (1096,6) to motion_demean.0_margin (1096*3,6)
 #~/Github/labs/GP/scripts/concatenate.motion_demean.0_margin.py -s $subj --dir_preproc $dir_preproc

cd $dir_output
## 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
3dDeconvolve																			\
	-input "$dir_preproc/pb06.$subj.r0?.scale+tlrc.HEAD"								\
	-censor "$dir_preproc/motion_${subj}_censor.1D"										\
	-mask "$dir_preproc/full_mask.$subj+tlrc.HEAD"										\
    -ortvec "$dir_preproc/motion_demean.1D" 'motion_demean'								\
	-polort A -float																	\
	-allzero_OK																			\
	-num_stimts 1																		\
	-stim_times_AM2 1 "$dir_reg/$subj.AM.onset-reward.1D" 'SPMG2' -stim_label 1 'Rew'	\
	-num_glt 1																			\
	-gltsym 'SYM: Rew' -glt_label 1 'Rew'												\
	-jobs 1 -fout -tout																	\
	-x1D "X.xmat.$subj.1D" -xjpeg "X.$subj.jpg"											\
	-bucket "stats.Rew.$subj"

echo " Calculating GLM for subject $subj completed"

 #3dDeconvolve \
 #	-input pb04.GA01.r01.scale+tlrc.HEAD \
 #	-censor motion_GA01.r01_censor.1D -mask full_mask.GA01+tlrc \
 #	-polort A -float \
 #	-allzero_OK \
 #	-num_stimts 7 \
 #	-stim_times_AM2 1 /Volumes/clmnlab/GA/behavior_data/GA01/GA01.r01rew1000.GAM.1D 'SPMG2' \
 #	-stim_label 1 rwdtm \
 #	-stim_file 2 'motion_demean.GA01.r01.1D[0]' -stim_base 2 -stim_label 2 roll \
 #	-stim_file 3 'motion_demean.GA01.r01.1D[1]' -stim_base 3 -stim_label 3 pitch \
 #	-stim_file 4 'motion_demean.GA01.r01.1D[2]' -stim_base 4 -stim_label 4 yaw \
 #	-stim_file 5 'motion_demean.GA01.r01.1D[3]' -stim_base 5 -stim_label 5 dS \
 #	-stim_file 6 'motion_demean.GA01.r01.1D[4]' -stim_base 6 -stim_label 6 dL \
 #	-stim_file 7 'motion_demean.GA01.r01.1D[5]' -stim_base 7 -stim_label 7 dP \
 #	-gltsym 'SYM: rwdtm' -glt_label 1 rwdtm \
 #	-jobs 8 -fout -tout \
 #	-x1D /Volumes/clmnlab/GA/fmri_data/glm_results/am_reg_SPMG2/X.xmat.GA01.run01.SPMG2.1D \
 #	-bucket /Volumes/clmnlab/GA/fmri_data/glm_results/am_reg_SPMG2/statsRWDtime.GA01.run01.SPMG2 \
 #	-errts /Volumes/clmnlab/GA/fmri_data/glm_results/am_reg_SPMG2/errts.GA01.run01.SPMG2
