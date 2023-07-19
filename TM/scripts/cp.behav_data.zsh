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
dir_from=/mnt/ext4/NAS05/TM/behav_data
dir_to=/mnt/ext4/TM/behav_data/TM${nn}
if [ ! -d $dir_to ]; then
	mkdir -m 755 $dir_to
fi
## ========================================== ##
array=(`find $dir_from/*${nn}* -maxdepth 1 -type f -name "*.mat" ! -name "*model*" ! -name "*TML*"`)
for ss in $array
{
	tmp=(`echo $ss | tr '/' ' '`)
	fname=${tmp[-1]}

	cp -n $ss $dir_to/$fname
}
