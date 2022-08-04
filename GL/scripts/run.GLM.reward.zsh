#!/bin/zsh

list_subj=(03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

parallel -j8 /home/sungbeenpark/Github/labs/GL/scripts/GLM.reward.tcsh 'GL'{} ::: $list_subj
