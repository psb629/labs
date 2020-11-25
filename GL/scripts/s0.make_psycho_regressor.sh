#!/bin/tcsh

set TR = 2

set root_dir = /Volumes/T7SSD1/GL
set reg_dir = $root_dir/behav_data/regressors
set ppi_dir = $root_dir/ppi
set output_dir = $ppi_dir/reg
if ( ! -d $output_dir ) then
	mkdir $output_dir
endif

set subj_list = (03 04 05 06 07 08 09 10 11 12 14 15 16 17 18 19 20 21 22 24 25 26 27 29)

set cond_list = (FB nFB)
echo "1 0" >$root_dir/val_FB.1D
echo "0 1" >$root_dir/val_nFB.1D

set runs = `count -digits 2 1 4`

foreach ss ($subj_list)
	set subj = GL$ss
	set reg_FB = $reg_dir/${subj}_FB.txt
	set reg_nFB = $reg_dir/${subj}_nFB.txt
	##==============================================================================================
	## split onset-times and duration which are extracted from each regressor file,
	## then make temporal text files
	foreach cond ($cond_list)
		set reg_data = $reg_dir/${subj}_${cond}.txt
		set output = $output_dir/onset.$subj.split.$cond.txt
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
	##==============================================================================================
	## combine onsets(FB and nFB) each run separately 
	set FB_data = $output_dir/onset.$subj.split.FB.txt
	set nFB_data = $output_dir/onset.$subj.split.nFB.txt
	foreach run ($runs)
		set FB = `head -${run} $FB_data | tail -1`
		set nFB = `head -${run} $nFB_data | tail -1`
		set output = $output_dir/onset.$subj.r$run.all_cond.1D
		if ( -e $output ) then
			rm $output
		endif
		set temp = ()
		foreach i (`count 1 $#FB`)
			set temp = ($temp $FB[$i] $nFB[$i])
		end
		echo $temp >$output
	end
	##==============================================================================================
	## round the values which mean onset-time in the files
	foreach run ($runs)
		set output = $output_dir/onset.$subj.rnd.r$run.all_cond.1D
		if ( -e $output ) then
			rm $output
		endif
		head -${run} $output_dir/onset.$subj.r$run.all_cond.1D | tail -1 >$root_dir/a.1D
		1dtranspose $root_dir/a.1D >$root_dir/b.1D
		1deval -a $root_dir/b.1D -expr 'int(a)+1-isnegative(10*(a-int(a))-5)' >$root_dir/c.1D
		1dtranspose $root_dir/c.1D >$root_dir/d.1D
		set temp = `cat $root_dir/d.1D`
		echo $temp >$output
	end
	rm $root_dir/?.1D
	##==============================================================================================
	## make psych-regressor
	foreach cond ($cond_list)
		set val = `cat $root_dir/val_$cond.1D`
		foreach run ($runs)
			set onset = `cat $output_dir/onset.$subj.rnd.r$run.all_cond.1D`
			set output = $output_dir/psych.$subj.r$run.$cond.1D
			if ( -e $output ) then
				rm $output
			endif
			foreach i (`count -digits 1 1 300`)
				@ tt = $i * $TR
				if ( $tt <= $onset[1] ) then
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
				else if ( $tt < $onset[7] ) then
					echo $val[2] >>$output
				else if ( $tt < $onset[8] ) then
					echo $val[1] >>$output
				else if ( $tt < $onset[9] ) then
					echo $val[2] >>$output
				else if ( $tt < $onset[10] ) then
					echo $val[1] >>$output
				else if ( $tt < $onset[11] ) then
					echo $val[2] >>$output
				else if ( $tt < $onset[12] ) then
					echo $val[1] >>$output
				else	# $tt >= $onset[12]
					echo $val[2] >>$output
				endif
			end
		end
	end
	##==============================================================================================
	## remove all temporal files
	rm $output_dir/onset.$subj.*
end
