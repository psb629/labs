#!/bin/zsh

## ============================================================ ##
## default
tt=0
cc='On'
## ============================================================ ##
while (( $# )); do
	key="$1"
	case $key in
		-s | --subject)
			subj="$2"
		;;
		-t | --time_shift)
			tt="$2"
		;;
		-c | --condition)
			cc="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
time_shift=`printf "%.1f\n" $tt`
## ============================================================ ##
dir_behav="/home/sungbeenpark/Github/labs/GL/behav_data"
dir_reg="$dir_behav/regressors/AM"

dir_root="/mnt/ext4/GL"
dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data.SSKim/$subj"
## ============================================================ ##
case $cc in
	'on' | 'On')
		cond='On'
	;;
	'off' | 'Off')
		cond='Off'
	;;
	'test' | 'Test')
		cond='Test'
	;;
esac
case $cond in
	'Test')
		task='test'
		runs=(`seq -f "r%02g" 6 1 7`)
		reg="$dir_reg/$subj.reward.$task.shift=${time_shift}.txt"
	;;
	*)
		task='main'
		runs=(`seq -f "r%02g" 2 1 5`)
		reg="$dir_reg/$subj.reward.${task}_${cond}.shift=${time_shift}.txt"
	;;
esac
## ============================================================ ##
MD="$dir_preproc/motion.demean.$task.1D"
if [ -f $MD ]; then
	rm $MD
fi
MC="$dir_preproc/motion.censor.$task.1D"
if [ -f $MC ]; then
	rm $MC
fi
input=()
for run in $runs
{
	cat "$dir_preproc/motion_demean.$subj.$run.1D" >> $MD

	cat "$dir_preproc/motion_$subj.${run}_censor.1D" >> $MC

	input=($input "$dir_preproc/pb04.$subj.$run.scale+tlrc.HEAD")
}
## ============================================================ ##
dir_output="$dir_fmri/stats/AM/GLM.reward_per_trial/${time_shift}s_shifted/$subj/$cond"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
cd $dir_output
3dDeconvolve														\
	-input		$input												\
	-mask		"$dir_preproc/full_mask.$subj+tlrc.HEAD"			\
	-censor		$MC													\
    -ortvec		$MD 'motion_demean'									\
	-polort A -float												\
	-allzero_OK														\
	-num_stimts 1													\
	-stim_times_AM2 1 $reg 'BLOCK(1,1)' -stim_label 1 'Rew'			\
	-jobs 1 -fout -tout												\
	-x1D "X.xmat.$subj.$cond.1D" -xjpeg "X.$subj.$cond.jpg"			\
	-x1D_uncensored "X.xmat.uncensored.$subj.$cond.1D"				\
	-bucket "stats.Rew.$subj.$cond.nii"

echo " Calculating GLM for subject $subj completed"
