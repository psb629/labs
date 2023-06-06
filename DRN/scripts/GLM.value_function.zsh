#!/bin/zsh

## ============================================================ ##
while (( $# )); do
	key="$1"
	case $key in
		-s | --subject)
			subj="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
dir_root="/mnt/ext5/DRN"

dir_behav="$dir_root/behav_data"
dir_reg="$dir_behav/regressors/AM/value"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj"
## ============================================================ ##
dir_output="$dir_fmri/stats/GLM/AM/value_function/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
## concatenating regressors
reg=$dir_output/reg.txt
for run in `seq -f 'r%02g' 1 6`
{
	cat $dir_reg/$subj.$run.value.txt >> $reg
	echo "" >> $reg
}
## ============================================================ ##
cd $dir_output
3dDeconvolve	\
	-input		$dir_preproc/pb06.$subj.r0?.scale+tlrc.HEAD		\
	-mask		$dir_preproc/full_mask.$subj+tlrc.HEAD			\
	-censor		$dir_preproc/censor_${subj}_combined_2.1D		\
	-ortvec		$dir_preproc/motion_demean.1D 'motion_demean'	\
	-polort A	-float											\
	-allzero_OK													\
	-num_stimts 1												\
	-stim_times_AM2 1 $reg 'BLOCK(1,1)' -stim_label 1 'Val'		\
	-jobs 1 -fout -tout											\
	-x1D "X.$subj.1D" -xjpeg "X.$subj.jpg"						\
	-x1D_uncensored "X.uncensored.$subj.1D"						\
	-bucket "stats.Val.$subj.nii"

echo " Calculating GLM for subject $subj completed"
