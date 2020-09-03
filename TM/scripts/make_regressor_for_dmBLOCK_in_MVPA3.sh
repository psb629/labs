#!/bin/tcsh

# This script will make the onset+duration data files respect for several stimulous for dmBLOCK command.

#set subj_list = (\
#				TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT TML10_PILOT TML11_PILOT\
#				TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20\
#				TML21 TML22 TML23 TML24 TML25 TML26\
#				)
set subj_list = (TML28 TML29)

set behav_dir = /clmnlab/TM/behav_data
######################## essential materials from Subj ########################
# onset_vibration.dat
# onset_yellow.dat

foreach subj ($subj_list)
	set subj_reg_dir = $behav_dir/regressors/$subj
	######################## make onset:duration data of vibration and yellow ########################
	set onVib = $subj_reg_dir/onset_vibration.dat
	set onYel = $subj_reg_dir/onset_yellow.dat
	
	set file_resultV = $subj_reg_dir/onset+duration_vibration.dat
	set file_resultY = $subj_reg_dir/onset+duration_yellow.dat
	
	if (-e $file_resultV) then
		echo renew $file_resultV
		rm $file_resultV
	endif
	if (-e $file_resultY) then
		echo renew $file_resultY
		rm $file_resultY
	endif
	
	foreach run (r01 r02 r03)
		set rr = `echo $run | cut -c3`
		set vO = `sed -n "${rr}p" $onVib`
		set vD = 1
		set yO = `sed -n "${rr}p" $onYel`
		set yD = 1.5
	
		foreach i (`count -digit 1 1 $#vO`)
			echo -n $vO[$i]\:$vD' '  >> $file_resultV
		end
		echo '' >> $file_resultV
		foreach i (`count -digit 1 1 $#yO`)
			echo -n $yO[$i]\:$yD' '  >> $file_resultY
		end
		echo '' >> $file_resultY
	end
	
	######################## combine above data ########################
	set file_resultCOY = $subj_reg_dir/onset+duration_COY.dat		# Vibration(Center, Others) / Yellow cross
	
	if (-e $file_resultCOY) then
		echo renew $file_resultCOY
		rm $file_resultCOY
	endif
	
	foreach run (r01 r02 r03)
		set rr = `echo $run | cut -c3`
		set v = `sed -n "${rr}p" $file_resultV`
		set y = `sed -n "${rr}p" $file_resultY`
	
		set num_start = 1			# Because array[0] isn't exist. array[1] is start.
		set num_trials = $#y
		foreach i (`count -digit 1 $num_start $num_trials`)		# count starts from $num_start
			@ before = $i * 2 - 1
			@ after = $i * 2
			echo -n $v[$before] $v[$after] $y[$i]' '  >> $file_resultCOY
		end
		echo '' >> $file_resultCOY
	end
################################################
	echo "done for $subj"
end

