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
dir_root="/mnt/ext5/GP/fmri_data/stats"
dir_stat="$dir_root/AM/GLM.reward_per_trial/${time_shift}s_shifted"
## ============================================================ ##
list_dname=(`find $dir_stat -maxdepth 1 -type d -name "GP??"`)
## ============================================================ ##
 #conda activate GA
for dname in $list_dname
{
	fname=`find $dname -type f -name "stats.Rew.GP??.nii"`

	dof=`3dinfo -verb $fname'[Rew#1_Tstat]' | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`

	tmp=$dname/tmp.nii
	3dcalc -a $fname'[Rew#1_Tstat]' -expr 'a' -prefix $tmp

	TtoZ --t_stat_map=$tmp --dof=$dof --output_nii="$dname/Rew#1_Zstat.nii"
	rm $tmp
}
