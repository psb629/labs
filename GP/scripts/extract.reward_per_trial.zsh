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
		-a | --analysis)
			analysis="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
if [ ! $tt ]; then
	tt=0
fi
tmp=`printf "%.1f\n" $tt`
time_shift="${tmp}s_shifted"
## ============================================================ ##
case $analysis in
	'GLM' | 'glm')
		analysis='GLM'
	;;
	'3dREMLfit' | '3dremlfit')
		analysis='3dREMLfit'
	;;
	*)
		analysis='GLM'
	;;
esac
## ============================================================ ##
dir_root="/mnt/ext5/GP/fmri_data/stats"
dir_stat="$dir_root/AM/$analysis.reward_per_trial/$time_shift/$subj"

dir_output=$dir_stat
## ============================================================ ##
 #conda activate GA
fname="$dir_stat/stats.Rew.$subj.$run.nii"
for prop in 'Rew#1_Coef' 'Rew#1_Tstat'
{
	pname="$dir_output/$prop.$run.$subj.nii"
	3dcalc -a "${fname}[$prop]" -expr 'a' -prefix $pname
	if [ $prop = 'Rew#1_Tstat' ]; then
		dof=`3dinfo -verb $pname | grep -o -E 'statpar = [0-9]+' | grep -o -E '[0-9]+'`
		TtoZ --t_stat_map=$pname --dof=$dof \
			--output_nii="$dir_output/Rew#1_Zstat.$run.$subj.nii"
	fi
}
