#!/bin/zsh

## ============================================================ ##
## default
job=4
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		--from)
			from="$2"
		;;
		--to_dir)
			dir_to="$2"
		;;
		--job)
			job="$2"
		;;
	esac
	shift ##takes one argument
done
label="${from[-4,-1]}"
## ============================================================ ##
dir_current=`pwd`
if [ ! -d $dir_to ]; then
	mkdir -p -m 755 $dir_to
fi

if [ -d $from ]; then
	## make directories in the objective directory
	find $from -type d >"$dir_current/dir_from.$label.txt"
	sed "s;$from;$dir_to;g" $dir_current/dir_from.$label.txt >"$dir_current/dir_to.$label.txt"

	for dir (`cat "$dir_current/dir_to.$label.txt"`)
	{
		if [ ! -d $dir ]; then
			mkdir -p -m 755 $dir
		fi
	}
fi

## make a list of file names to copy them
find $from -type f >"$dir_current/file_from.$label.txt"
sed "s;$from/;;g" $dir_current/file_from.$label.txt >"$dir_current/fname.$label.txt"

 ### If the number of arguments > 4000, error would be occured.
 #xargs -n 3500 -a "$dir_current/fname.txt" -i parallel -j8 cp -n "$from/{}" "$dir_to/{}"
 #cat $dir_current/fname.txt | xargs -n3500 echo >$dir_current/tmp.txt

## If the number of arguments > 4000, error would be occured.
parallel -0 -j${job} cp -n "$from/{}" "$dir_to/{}" ::: `cat "$dir_current/fname.$label.txt"`

## remove temporal files
rm "$dir_current/dir_from.$label.txt" "$dir_current/dir_to.$label.txt"
rm "$dir_current/file_from.$label.txt" "$dir_current/fname.$label.txt"
