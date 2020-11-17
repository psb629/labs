#!/bin/tcsh

set TR = 2

set root_dir = /Volumes/T7SSD1/GL
set reg_dir = $root_dir/behav_data/regressors
set output_dir = $root_dir/ppi

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)
set subj = GL${subj_list[1]}

set cond_list = (FB nFB)
echo "1 0" >./val_FB.1D
echo "0 1" >./val_nFB.1D

set reg_FB = $reg_dir/${subj}_FB.txt
set reg_nFB = $reg_dir/${subj}_nFB.txt

set runs = `count -digits 2 1 4`

## split onset times which are extracted from each regressor file, then make temporal text files
foreach cond ($cond_list)
	set reg_data = $reg_dir/${subj}_${cond}.txt
	set output = ./onset_${cond}.txt
	if ( -e $output ) then
		rm $output
	endif
	#cat $reg_data
	foreach run ($runs)
		set line = `head -${run} $reg_data | tail -1`
		set split = `echo $line:q | sed 's/:/ /g'` # ':q' : Quote modifier. $line:q acts like "$line"
		set onset = ()
		set durs = ()
		foreach i (`count 1 $#line`)
			@ odd = $i * 2 - 1
			@ even = $i * 2
			set onset = ($onset $split[$odd])
			set durs = ($durs $split[$even])
		end
		echo $onset >>$output
	end
end

## combine above temporal files each run separately 
 #set FB_data = ./onset_FB.txt
 #set nFB_data = ./onset_nFB.txt
 #foreach run ($runs)
 #	set FB = `head -${run} $FB_data | tail -1`
 #	set nFB = `head -${run} $nFB_data | tail -1`
 #	set output = ./onset.r$run.1D
 #	if ( -e $output ) then
 #		rm $output
 #	endif
 #	set temp = ()
 #	foreach i (`count 1 $#FB`)
 #		set temp = ($temp $FB[$i] $nFB[$i])
 #	end
 #	echo $temp >$output
 #	## convert floats to integers
 #	1dtranspose $output >temp.1D
 #	1deval -a temp.1D -expr 'int(a)' >$output
 #	1dtranspose $output >temp.1D
 #	set temp = `cat temp.1D`
 #	echo $temp >$output
 #end
 #rm temp.1D

## round the values in the files
foreach cond ($cond_list)
	foreach run ($runs)
		head -${run} ./onset_$cond.txt | tail -1 >a.1D
		1dtranspose a.1D >b.1D
		1deval -a b.1D -expr 'int(a)+1-isnegative(10*(a-int(a))-5)' >c.1D
		1dtranspose c.1D >d.1D
		set temp = `cat d.1D`
		echo $temp >onset.r$run.$cond.1D
	end
end
rm ./?.1D

## make psych-regressor
foreach cond ($cond_list)
	set val = `cat val_$cond.1D`
	foreach run ($runs)
		set onset = `cat ./onset.r$run.$cond.1D`
		set output = ./psych_reg.r$run.$cond.1D
		if ( -e $output ) then
			rm $output
		endif
		foreach i (`count -digits 1 1 300`)
			@ tt = $i * $TR
			if ( $tt < $onset[1] ) then
				echo $val[2] >>$output
			else if ( $tt < $onset[2] ) then
				echo $val[1] >>$output
			else if ( $tt < $onset[3] ) then
				echo $val[2] >>$output
			else if ( $tt < $onset[4] ) then
				echo $val[1] >>$output
			else if ( $tt < $onset[5] ) then
				echo $val[2] >>$output
			else if ( $tt < $onset[6] ) then
				echo $val[1] >>$output
			else
				echo $val[2] >>$output
			endif
		end
	end
end

##
rm ./onset_*B.txt ./onset.r??.*.1D