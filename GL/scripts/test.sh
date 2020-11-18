#!/bin/tcsh

 #set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
 #
 #set root_dir = /Volumes/clmnlab/GL/fmri_data/
 #set obj_dir = /Volumes/T7SSD1/GL/fMRI_data/
 #
 #foreach cc ($subj_list)
 #	set subj = GL$cc
 #	if ( ! -e $obj_dir/$subj/motion_demean.$subj.r02_05.1D ) then
 #		cp $root_dir/$subj/preprocessed/motion_demean.$subj.r02_05.1D $obj_dir/$subj/
 #	else
 #		echo "motion_demean.$subj.r02_05.1D already exists!"
 #	endif
 #	if ( ! -e $obj_dir/$subj/motion_censor.$subj.r02_05.1D ) then
 #		cp $root_dir/$subj/preprocessed/motion_$subj.r02_05.censor.1D $obj_dir/$subj/motion_censor.$subj.r02_05.1D
 #	else
 #		echo "motion_censor.$subj.r02_05.1D already exists!"
 #	endif
 #end
# ============================================================
set cc = 2
@ xx = $cc - 1
echo $xx
printf '%02d\n' $xx
# ============================================================
set root_dir = /Volumes/T7SSD1/GL
set ppi_dir = $root_dir/ppi
set TR = 2
set subj = GL03
#set cond_list = (FB nFB)
set cond_list = (FB)
#set runs = (01 02 03 04)
set runs = (01)
 #foreach cond ($cond_list)
 #	set val = `cat $root_dir/val_$cond.1D`
 #	echo "val : $val"
 #	foreach run ($runs)
 #		set onset = `cat $ppi_dir/onset.$subj.r$run.$cond.1D`
 #		echo "onset : $onset"
 #		foreach i (`count -digits 1 1 300`)
 #			@ tt = $i * $TR
 #			if ( $tt <= $onset[1] ) then
 #				echo "$tt <= $onset[1] : $val[2]"
 #			else if ( $tt < $onset[2] ) then
 #				echo "$tt < $onset[2] : $val[1]"
 #			else if ( $tt < $onset[3] ) then
 #				echo "$tt < $onset[3] : $val[2]"
 #			else if ( $tt < $onset[4] ) then
 #				echo "$tt < $onset[4] : $val[1]"
 #			else if ( $tt < $onset[5] ) then
 #				echo "$tt < $onset[5] : $val[2]"
 #			else if ( $tt < $onset[6] ) then
 #				echo "$tt < $onset[6] : $val[1]"
 #			else	# $tt >= $onset[6]
 #				echo "$tt >= $onset[6] : $val[2]"
 #			endif
 #		end
 #	end
 #end
# ============================================================
echo "1deval"
1deval -a $ppi_dir/psych.$subj.r01.FB.1D -b $ppi_dir/psych.$subj.r01.nFB.1D -expr 'a+b'
