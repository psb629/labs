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
## ============================================================ ##
dir_root="/mnt/ext4/GL"
dir_fmri="$dir_root/fmri_data"
dir_stat="$dir_fmri/stats/AM/GLM.reward_per_trial/${time_shift}s_shifted/$subj/$cond"
## ============================================================ ##
ls $dir_stat
cd $dir_stat
3dcalc	\
	-a "stats.Rew.$subj.$cond.nii[Rew#1_Coef]"	\
	-expr 'a'									\
	-prefix "Rew#1_Coef.$subj.$cond.nii"
