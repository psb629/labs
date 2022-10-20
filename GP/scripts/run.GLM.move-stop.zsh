#!/bin/zsh

dir_script="/home/sungbeenpark/Github/labs/GP/scripts"
list_nn=( 08 09 10 11 17 \
		  18 19 20 21 22 \
		  24 26 27 32 33 \
		  34 35 36 37 38 \
		  39 40 41 42 43 \
		  44 45 46 47 48 \
		  49 50 51 53 54 \
		  55 )

parallel -j8 $dir_script/GLM.move-stop.zsh "GP{}" ::: $list_nn
