#!/bin/zsh

#=============================================
list_nn=( 08 09 10 11 17 18 19 20 21 22 \
		  24 26 27 32 33 34 35 36 37 38 \
		  39 40 41 42 43 44 45 46 47 48 \
		  49 50 51 53 54 55 )
#=============================================
dir_from="/mnt/ext2/GP/fmri_data/preproc_data"
dir_to="/mnt/ext7/GP/fmri_data/preproc_data"
#=============================================
##copy directories
find "$dir_from" -type d | sed "s;$dir_from;$dir_to;g" | xargs mkdir -p -m 755
##copy files
find "$dir_from" -type f | sed "s;$dir_from;;g" >$dir_from/list_fname.txt
## If the number of arguments > 4000, error would be occured.
cat $dir_from/list_fname.txt | xargs -n1 | parallel -j8 cp -r -n "$dir_from{}" "$dir_to{}"
 #parallel -j8 cp -r -n "$dir_from{}" "$dir_to{}" ::: `cat $dir_from/list_fname.txt`
