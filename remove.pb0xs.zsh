#!/bin/zsh

## =============================================== ##
dir_work=`pwd`
## =============================================== ##
## =============================================== ##
list=(`find $dir_work -type f -name "pb??.*" ! -name "*scale*" ! -name "*volreg*" ! -name "*blip*" -print`)
if [ `echo $list | wc -l` -gt 1 ]; then
	find $dir_work -type f -name "pb??.*" ! -name "*scale*" ! -name "*volreg*" ! -name "*blip*" -print
else
	exit
fi
## =============================================== ##
echo "Do you want to remove the list? (yes/no)"
read input
## =============================================== ##
case $input in
	'y' | 'yes' | 'Y' | 'Yes' | 'YES')
		find $dir_work -type f -name "pb??.*" ! -name "*scale*" ! -name "*volreg*" ! -name "*blip*" -delete
	;;
	*)
		exit
	;;
esac
