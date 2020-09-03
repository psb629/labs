#!/bin/tcsh

# This script will make the onset+duration data files respect for several stimulous for dmBLOCK command.

set subj_list = (KJW)

set behav_dir = /clmnlab/TM/behav_data
######################## essential materials from Subj ########################
# onset_ISI1.dat
# onset_ISI2.dat
# duration_ISI1.dat
# duration_ISI2.dat
# onset_vibration.dat
# onset_yellow.dat

foreach subj ($subj_list)
	set subj_reg_dir = $behav_dir/regressors/$subj
	######################## make onset:duration data around ISI1 and ISI2 ########################
	set onISI1 = $subj_reg_dir/onset_ISI1.dat
	set onISI2 = $subj_reg_dir/onset_ISI2.dat
	set durISI1 = $subj_reg_dir/duration_ISI1.dat
	set durISI2 = $subj_reg_dir/duration_ISI2.dat
	set tempO = $subj_reg_dir/tempIO.dat
	set tempD = $subj_reg_dir/tempID.dat
	
	set file_result = $subj_reg_dir/onset+duration_ISI12.dat
	
	if (-e $file_result) then
		echo renew $file_result
		rm $file_result
	endif
	
	foreach run (r01 r02 r03 r04 r05)
		set rr = `echo $run | cut -c3`
		set I1O = `sed -n "${rr}p" $onISI1`
		set I2O = `sed -n "${rr}p" $onISI2`
		set I1D = `sed -n "${rr}p" $durISI1`
		set I2D = `sed -n "${rr}p" $durISI2`
	
		foreach i (`count -digit 1 1 $#I1O`)
			echo -n "$I1O[$i] $I2O[$i] " >> $tempO
			echo -n "$I1D[$i] $I2D[$i] " >> $tempD
		end
		echo '' >> $tempO
		echo '' >> $tempD
	
		set IOn = `cat $tempO`
		set IDur = `cat $tempD`
		rm $tempO $tempD
	
		foreach i (`count -digit 1 1 $#IOn`)
			echo -n $IOn[$i]\:$IDur[$i]' '  >> $file_result
		end
		echo '' >> $file_result
	end
	######################## make onset:duration data of vibration, yellow ########################
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
	
	foreach run (r01 r02 r03 r04 r05)
		set rr = `echo $run | cut -c3`
		set vO = `sed -n "${rr}p" $onVib`
		set vD = 2
		set yO = `sed -n "${rr}p" $onYel`
		set yD = 2
	
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
	set file_resultVWM = $subj_reg_dir/onset+duration_VWM.dat		# Vibration / Working-memory / Motor response
	
	if (-e $file_resultVWM) then
		echo renew $file_resultVWM
		rm $file_resultVWM
	endif
	
	foreach run (r01 r02 r03 r04 r05)
		set rr = `echo $run | cut -c3`
		set v = `sed -n "${rr}p" $file_resultV`
		set isi = `sed -n "${rr}p" $file_result`
		set y = `sed -n "${rr}p" $file_resultY`
	
		set num_trials = $#y
		foreach i (`count -digit 1 1 $num_trials`)
			@ before = $i * 2 - 1
			@ after = $i * 2
			echo -n $v[$before] $isi[$before] $v[$after] $isi[$after] $y[$i]' '  >> $file_resultVWM
		end
		echo '' >> $file_resultVWM
	end
	################################################
	echo "done for $subj"
end

