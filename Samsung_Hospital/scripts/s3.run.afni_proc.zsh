#!/bin/zsh

## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-p | --phase)
			phase="$2"
		;;
	esac
	shift ##takes one argument
done

dir_script="/home/sungbeenpark/Github/labs/Samsung_Hospital/scripts/afni_proc.py/$phase"
list_fname=(`find $dir_script -type f -name "proc.S??" | sort`)

dir_root="/mnt/ext5/SMC/fmri_data"
dir_raw="$dir_root/raw_data/$phase"
dir_preproc="$dir_root/preproc_data/$phase.anaticor"

dir_output=$dir_preproc

for fname in $list_fname
{
	subj=${fname[-3,-1]}
	if [ -d $dir_output/$subj ]; then
		continue
	fi
	$fname
}
