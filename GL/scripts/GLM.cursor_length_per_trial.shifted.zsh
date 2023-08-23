#!/bin/zsh

## ============================================================ ##
## default
tt=0
cc='main'
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
time_shift=`printf "%1d\n" $tt`
## ============================================================ ##
dir_behav="/home/sungbeenpark/Github/labs/GL/behav_data"
dir_reg="$dir_behav/regressors/AM/cursor_length/shift=$time_shift"

dir_root="/mnt/ext4/GL"
dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data.SSKim/$subj"
## ============================================================ ##
case $cc in
	'on|off' | 'On|Off')
		cond='on|off'
	;;
	'test' | 'Test')
		cond='test'
	;;
	'main' | 'Main')
		cond='main'
	;;
	'all' | 'All')
		cond='all'
	;;
esac
case $cond in
	'test')
		list_run=(`seq -f "r%02g" 6 1 7`)
	;;
	'all')
		list_run=(`seq -f "r%02g" 2 1 7`)
	;;
	*)
		list_run=(`seq -f "r%02g" 2 1 5`)
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
for run in $list_run
{
	cat "$dir_preproc/motion_demean.$subj.$run.1D" >> $MD

	cat "$dir_preproc/motion_$subj.${run}_censor.1D" >> $MC

	input=($input "$dir_preproc/pb04.$subj.$run.scale+tlrc.HEAD")
}
## ============================================================ ##
dir_output="$dir_fmri/stats/AM/GLM.cursor_length_per_trial/${time_shift}s_shifted/$subj/$cond"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
cd $dir_output
case $cond in
	'on|off')
		regon="$dir_reg/$subj.cursor.shift=$time_shift.on.rall.txt"
		regoff="$dir_reg/$subj.cursor.shift=$time_shift.off.rall.txt"
		3dDeconvolve														\
			-input		$input												\
			-mask		"$dir_preproc/full_mask.$subj+tlrc.HEAD"			\
			-censor		$MC													\
		    -ortvec		$MD 'motion_demean'									\
			-polort A -float												\
			-allzero_OK														\
			-num_stimts 2													\
			-stim_times_AM2 1 $regon 'BLOCK(1,1)' -stim_label 1 'LenOn'		\
			-stim_times_AM2 2 $regoff 'BLOCK(1,1)' -stim_label 2 'LenOff'	\
			-jobs 1 -fout -tout												\
			-x1D "X.xmat.$subj.$cond.1D" -xjpeg "X.$subj.$cond.jpg"			\
			-x1D_uncensored "X.xmat.uncensored.$subj.$cond.1D"				\
			-bucket "stats.Len.$subj.$cond.nii"
	;;
	*)
		reg="$dir_reg/$subj.cursor.shift=$time_shift.$cond.rall.txt"
		3dDeconvolve														\
			-input		$input												\
			-mask		"$dir_preproc/full_mask.$subj+tlrc.HEAD"			\
			-censor		$MC													\
		    -ortvec		$MD 'motion_demean'									\
			-polort A -float												\
			-allzero_OK														\
			-num_stimts 1													\
			-stim_times_AM2 1 $reg 'BLOCK(1,1)' -stim_label 1 'Len'			\
			-jobs 1 -fout -tout												\
			-x1D "X.xmat.$subj.$cond.1D" -xjpeg "X.$subj.$cond.jpg"			\
			-x1D_uncensored "X.xmat.uncensored.$subj.$cond.1D"				\
			-bucket "stats.Len.$subj.$cond.nii"
	;;
esac

echo " Calculating GLM for subject $subj completed"
