#!/bin/zsh

#=============================================
list_nn=( 08 09 10 11 17 18 19 20 21 22 \
		  24 26 27 32 33 34 35 36 37 38 \
		  39 40 41 42 43 44 45 46 47 48 \
		  49 50 51 53 54 55 )
#=============================================
dir_from="/mnt/ext6/GP_KJH/fmri_data/raw_data"
dir_to="/mnt/ext6/GP/fmri_data/raw_data"
#=============================================
##copy directories
find "$dir_from" -type d | sed "s;$dir_from;$dir_to;g" | xargs mkdir -p -m 755
##copy files
find "$dir_from" -type f | sed "s;$dir_from;;g" >list_fname.txt
## If the number of arguments > 4000, error would be occured.
cat ./list_fname.txt | xargs -n1 | parallel -j8 cp -r -n "$dir_from{}" "$dir_to{}"
 #parallel -j8 cp -r -n "$dir_from{}" "$dir_to{}" ::: `cat list_fname.txt`
