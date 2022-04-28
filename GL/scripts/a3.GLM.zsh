#!/bin/zsh

list_nn=(03 04 05 06 07 \
		08 09 10 11 12 \
		14 15 16 17 18 \
		19 20 21 22 24 \
		25 26 27 29)

dir_script=/home/sungbeenpark/Github/labs/GL/scripts

parallel -j 24 $dir_script/GLM.reward.tcsh {1}{2} ::: "GL" ::: $list_nn
