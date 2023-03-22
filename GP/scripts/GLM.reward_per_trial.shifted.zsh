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
			subj="$2"
		;;
		-t | --time_shift)
			tt="$2"
		;;
		-r | --run)
			run="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
if [ ! $tt ]; then
	tt=0
fi
time_shift=`printf "%.1f\n" $tt`
stat="${time_shift}s_shifted"
## ============================================================ ##
dir_script="/home/sungbeenpark/Github/labs/GP/scripts"

dir_root="/mnt/ext5/GP"

dir_behav="$dir_root/behav_data"
dir_reg="$dir_behav/regressors/AM/$stat"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj/day2"
## ============================================================ ##
 #sudo chown -R sungbeenpark:clmnlab $dir_reg
 #sudo chmod -R 755 $dir_reg
dir_tmp="/home/sungbeenpark/tmp"
if [ ! -d $dir_tmp ]; then
	mkdir -p -m 755 $dir_tmp
fi
## ============================================================ ##
case $run in
	1 | 'r01')
		run='r01'
		rr=1
	;;
	2 | 'r02')
		run='r02'
		rr=2
	;;
	3 | 'r03')
		run='r03'
		rr=3
	;;
	*)
		run='rall'
	;;
esac
input=$dir_preproc/pb06.$subj.r0?.scale+tlrc.HEAD
censor=$dir_preproc/motion_${subj}_censor.1D
head=$dir_preproc/motion_demean.1D
regressor=$dir_reg/$subj.reward.txt
if [ $run != 'rall' ]; then
	input=$dir_preproc/pb06.$subj.$run.scale+tlrc.HEAD

	## censor
	fname=$dir_tmp/$subj.$run.censor.1D
	$dir_script/extract.lines.from_txt.py	\
		-i $censor							\
		-o $fname							\
		-a $(( 1096*($rr-1)+1 ))			\
		-b $(( 1096*$rr ))
	censor=$fname

	## head motion
	fname=$dir_tmp/$subj.$run.motion_demean.1D
	$dir_script/extract.lines.from_txt.py	\
		-i $head							\
		-o $fname							\
		-a $(( 1096*($rr-1)+1 ))			\
		-b $(( 1096*$rr ))
	head=$fname

	## regressor
	fname=$dir_tmp/$subj.$run.reward.1D
	$dir_script/extract.lines.from_txt.py	\
		-i $dir_reg/$subj.reward.txt		\
		-o $fname							\
		-a $rr								\
		-b $rr
	regressor=$fname
fi
## ============================================================ ##
dir_output="$dir_fmri/stats/AM/GLM.reward_per_trial/$stat/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
## convert motion_demean (1096,6) to motion_demean.0_margin (1096*3,6)
 #~/Github/labs/GP/scripts/concatenate.motion_demean.0_margin.py -s $subj --dir_preproc $dir_preproc

cd $dir_output
## 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
3dDeconvolve																			\
	-input $input																		\
	-censor $censor 																	\
	-mask "$dir_preproc/full_mask.$subj+tlrc.HEAD"										\
    -ortvec $head 'motion_demean'														\
	-polort A -float																	\
	-allzero_OK																			\
	-num_stimts 1																		\
	-stim_times_AM2 1 $regressor 'BLOCK(1,1)' -stim_label 1 'Rew'						\
	-num_glt 1																			\
	-gltsym 'SYM: Rew' -glt_label 1 'Rew'												\
	-jobs 1 -fout -tout																	\
	-x1D "X.xmat.$subj.$run.1D" -xjpeg "X.$subj.$run.jpg"								\
	-x1D_uncensored "X_uncensored.xmat.$subj.$run.1D"									\
	-bucket "stats.Rew.$subj.$run.nii"

echo " Calculating GLM for subject $subj completed"
