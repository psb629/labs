#!/bin/zsh

dir_current=`pwd`

dir_from=/mnt/sdb2/GP/fmri_data/preproc_data
dir_to=/mnt/ext6/GP/fmri_data/preproc_data

## make directories in the objective directory
find $dir_from -type d >$dir_current/dir_from.txt
sed "s.$dir_from.$dir_to.g" $dir_current/dir_from.txt >$dir_current/dir_to.txt
foreach dir (`cat $dir_current/dir_to.txt`)
	if [ ! -d $dir ]; then
		mkdir -p -m 755 $dir
	fi
end

## make a list of file names to copy them
find $dir_from -type f >$dir_current/dir_from.txt
sed "s;$dir_from;;g" $dir_current/dir_from.txt >$dir_current/fname.txt

## remove temporal files
rm $dir_current/dir_from.txt $dir_current/dir_to.txt

 #cat $dir_current/fname.txt | xargs -n3500 echo >$dir_current/tmp.txt

## If the number of arguments > 4000, error would be occured.
parallel -j10 cp -n $dir_from{} $dir_to{} ::: `cat $dir_current/fname.txt`

