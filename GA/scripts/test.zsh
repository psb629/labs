#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ==================================================================
x=1
let x+=1
echo 1:$x
((x+=1))
echo 2:$x
x=$[$x+1]
echo 3:$x
x=`expr $x + 1`
echo 4:$x
x=`echo "$x+1"|bc`
echo 5:$x
x=3.14
x=`echo "scale=2;$x*2"|bc`
echo 6:$x

foreach x (1 2)
	if [ $x -eq 1 ]; then
		echo "$x -eq 1 : true"
	 #elif [ ! $x -eq 1 ]; then
	 #	echo "false"
	 else;
	 	echo "$x -eq 1 : else"
	fi
end

foreach x (`count -digits 2 0 3`)
	if [ $x -eq "0" ]; then
		echo "$x finded!"
	else;
		echo "$x"
	fi
end

foreach n (`seq 1 30`)
	echo "nn_list[$n] == $nn_list[$n]"
end
# ==================================================================
 #nn_list=( 01 )
 #dname=GLM.MO
 #
 #data_dir=/Volumes/GoogleDrive/내\ 드라이브/GA/pb02
 #root_dir=/Volumes/GoogleDrive/내\ 드라이브/GA
 #behav_dir=$root_dir/behav_data
 #fmri_dir=$root_dir/fMRI_data
 #roi_dir=$fmri_dir/roi
 #stats_dir=$fmri_dir/stats
 #
 #foreach nn ($nn_list)
 #	foreach gg (GA)
 #		subj=$gg$nn
 #		foreach rr (01)
 #			## AM = Amplitude Modulation
 #			## The -stim_times_AM* options have been modified to allow the input of multiple amplidues with each time.
 #			## -stim_times_AM1 still builds only 1 regressor, as before amplitude of each BLOCK (say) is modulated by sum of all extra amplitudes provided.
 #			3dDeconvolve -nodata 1096 0.46 \
 #						-polort A -float \
 #						-num_stimts 1 \
 #						-num_glt 1 \
 #						-stim_times_AM1 1 $behav_dir/regressors/4targets/$subj.AMregressor.4targets.r$rr.1D 'BLOCK(5,1)' \
 #						-x1D /Users/clmn/Github/labs/GA/scripts/AM.$subj.r$rr -x1D_stop
 #		end
 #	end
 #end
