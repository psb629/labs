#!/bin/zsh
#===================================================
## KHBM WinterCamp2021
 #nn_list=( 01 02 05 07 08 \
 #		  11 12 13 14 15 \
 #		  18 19 20 21 23 \
 #		  26 27 28 29 30 \
 #		  31 32 33 34 35 \
 #		  36 37 38 42 44 )
 #
 #root_dir=~/Desktop/WinterCamp2021/preproc_data
 #output_dir=~/Desktop/betas
 #if [ ! -d $output_dir ]; then
 #	mkdir -p -m 755 $output_dir
 #fi
 #
 #foreach nn ($nn_list)
 #	cd $root_dir
 #	zip -r $output_dir/$nn.zip $nn
 #end
#===================================================
## backup iMac
root_dir=~/Desktop
output_dir=/Volumes/WD_HDD1/backup_iMac
if [ ! -d $output_dir ]; then
	mkdir -p -m 755 $output_dir
fi
target_list=(GA Kang GL 3T_210222)
foreach target ($target_list)
	cd $root_dir/$target
	zip -r $output_dir/$target.zip ./ -x "*.DS_Store"
	rm -r $root_dir/$target
end
#===================================================
## decompress
 #gzip -d *.gz
