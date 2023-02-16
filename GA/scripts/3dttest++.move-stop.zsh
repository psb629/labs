#!/bin/zsh

## ============================================================ ##
## default
dir_root="/mnt/ext5/GA"

dir_fmri="$dir_root/fmri_data"
dir_mask="$dir_fmri/masks"
dir_stat="$dir_fmri/stats/IM/GLM.move-stop"

dir_output=$dir_stat
## ============================================================ ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-GSR | --global_signal_regression)
			case $2 in
				'y' | 'yes')
					GSR=true
					list_fname=(`find $dir_stat/GA??.GS -type f -name "stats.move-stop.GA??.nii"`)
				;;
				*)
					GSR=false
					list_fname=(`find $dir_stat/GA?? -type f -name "stats.move-stop.GA??.nii"`)
				;;
			esac
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
mask="$dir_mask/mask.group.GA.n30.frac=0.7.nii"
## ============================================================ ##
cd $dir_output

setA=()
for fname in $list_fname
{
	setA=($setA $fname'[Move#0_Coef]')
}
setB=()
for fname in $list_fname
{
	setB=($setB $fname'[Stop#0_Coef]')
}
3dttest++														\
	-mask $mask													\
	-setA $setA													\
	-setB $setB													\
	-prefix group.move-stop.clustsim.n$#list_fname.GSR=$GSR.nii	\
	-ClustSim 4
## ============================================================ ##
 ### extract the Z stat
 #3dcalc -a GA.toz.n$#list_subj.nii'[SetA_Zscr]' -expr 'a' -prefix GA.Zscr.n$#list_subj.nii
