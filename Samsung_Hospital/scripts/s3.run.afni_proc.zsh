#!/bin/zsh

fs="with_FreeSurfer"
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
		-F | --FreeSurfer)
			if [[ ($2 == 'y') || ($2 == 'yes') ]]; then
				fs="with_FreeSurfer"
			elif [[ ($2 == 'n') || ($2 == 'no') ]]; then
				fs="without_FreeSurfer"
			fi
		;;
	esac
	shift ##takes one argument
done

dir_script="/home/sungbeenpark/Github/labs/Samsung_Hospital/scripts/afni_proc.py/$phase/$fs"
dir_root="/mnt/ext5/SMC/fmri_data"
 #dir_raw="$dir_root/raw_data/$phase"
dir_preproc="$dir_root/preproc_data/$phase.anaticor/$fs"

dir_output=$dir_preproc

list_subj=(`"/home/sungbeenpark/Github/labs/Samsung_Hospital/scripts/SMC_IDs.py" -p $phase`)
list_fname=()
for subj in $list_subj
{
	fname="$dir_script/proc.$subj"
	if [ -d $dir_output/$subj ]; then
		continue
	fi
	list_fname=($list_fname $fname)
}

## option #1
parallel -j8 "{}" ::: $list_fname

## option #2
 #for fname in $list_fname
 #	$fname
