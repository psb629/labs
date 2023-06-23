#!/bin/zsh

## =============================================== ##
dir_work=`pwd`
## =============================================== ##
list=(`find $dir_work -type f -name "pb??.*" ! -name "*scale*" ! -name "*volreg*" ! -name "*blip*" -print`)
if [ $#list -gt 1 ]; then
	for fname in $list
		print $fname
else
	echo " Clean!"
	exit
fi
## =============================================== ##
echo "Do you want to remove the list? (yes/no)"
read input
## =============================================== ##
case $input in
	'yes')
		find $dir_work -type f -name "pb??.*" ! -name "*scale*" ! -name "*volreg*" ! -name "*blip*" -delete
	;;
	*)
		exit
	;;
esac
