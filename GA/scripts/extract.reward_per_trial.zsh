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
dir_root="/mnt/ext5/GA/fmri_data/stats"
dir_stat="$dir_root/AM/GLM.reward_per_trial/${time_shift}s_shifted"
## ============================================================ ##
list_dname=(`find $dir_stat -maxdepth 1 -type d -name "GA??"`)
## ============================================================ ##
 #conda activate GA
for dname in $list_dname
{
	fname=`find $dname -type f -name "stats.Rew.GA??.nii"`

	## extract the coefficient
	output="$dname/Rew#1_Coef.nii"
	if [[ ! -f $output ]]; then
		3dcalc -a $fname'[Rew#1_Coef]' -expr 'a' -prefix $output
	fi

	## extract T-stat then transfer to Z-stat
	output="$dname/Rew#1_Zstat.nii"
	if [[ ! -f $output ]]; then
		tmp=$dname/tmp.nii
		3dcalc -a $fname'[Rew#1_Tstat]' -expr 'a' -prefix $tmp

		dof=`3dinfo -verb $fname'[Rew#1_Tstat]' | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
		TtoZ --t_stat_map=$tmp --dof=$dof --output_nii=$output
		rm $tmp
	fi
}
