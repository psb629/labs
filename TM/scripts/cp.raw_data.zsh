#!/bin/zsh

## ========================================== ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
		-s | --subject)
			subj="$2"
		;;
	esac
	shift ##takes one argument
done
## ========================================== ##
tmp=`echo $subj | tr -dc '0-9'`
nn=`printf '%02d\n' $tmp`
## ========================================== ##
dir_from=/mnt/ext4/NAS05/TM/fmri_data/raw_data
dir_to=/mnt/ext4/TM/fmri_data/raw_data
## ========================================== ##
list_dname=(`find $dir_from/*${nn}* -maxdepth 1 -type d`)
## ========================================== ##
zip -rq $dir_to/TM${nn}.zip ${list_dname[@]:1}
