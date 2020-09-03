#!/bin/tcsh

# This script will make the onset+duration data files respect for several stimulous for dmBLOCK command.

set subj_list = (\
				TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT TML10_PILOT TML11_PILOT\
				TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20\
				TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29\
				)

set behav_dir = /clmnlab/TM/behav_data
######################## essential materials from Subj ########################
# onset_ISI1.dat
# onset_ISI2.dat
# duration_ISI1.dat
# duration_ISI2.dat
# onset_vibration.dat
# onset_yellow.dat
# onset_coin.dat

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
	
	foreach run (r01 r02 r03)
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
	######################## make onset:duration data of vibration, yellow, and coin ########################
	set onVib = $subj_reg_dir/onset_vibration.dat
	set onYel = $subj_reg_dir/onset_yellow.dat
	set onCoi = $subj_reg_dir/onset_coin.dat
	
	set file_resultV = $subj_reg_dir/onset+duration_vibration.dat
	set file_resultY = $subj_reg_dir/onset+duration_yellow.dat
	set file_resultC = $subj_reg_dir/onset+duration_coin.dat
	
	if (-e $file_resultV) then
		echo renew $file_resultV
		rm $file_resultV
	endif
	if (-e $file_resultY) then
		echo renew $file_resultY
		rm $file_resultY
	endif
	if (-e $file_resultC) then
		echo renew $file_resultC
		rm $file_resultC
	endif
	
	foreach run (r01 r02 r03)
		set rr = `echo $run | cut -c3`
		set vO = `sed -n "${rr}p" $onVib`
		set vD = 1
		set yO = `sed -n "${rr}p" $onYel`
		set yD = 1.5
		set cO = `sed -n "${rr}p" $onCoi`
		set cD = 0.5
	
		foreach i (`count -digit 1 1 $#vO`)
			echo -n $vO[$i]\:$vD' '  >> $file_resultV
		end
		echo '' >> $file_resultV
		foreach i (`count -digit 1 1 $#yO`)
			echo -n $yO[$i]\:$yD' '  >> $file_resultY
		end
		echo '' >> $file_resultY
		foreach i (`count -digit 1 1 $#cO`)
			echo -n $cO[$i]\:$cD' '  >> $file_resultC
		end
		echo '' >> $file_resultC
	end
	######################## combine above data ########################
	set file_resultVWMR = $subj_reg_dir/onset+duration_VWMR.dat		# Vibration / Working-memory / Motor response / Reward
	
	if (-e $file_resultVWMR) then
		echo renew $file_resultVWMR
		rm $file_resultVWMR
	endif
	
	foreach run (r01 r02 r03)
		set rr = `echo $run | cut -c3`
		set v = `sed -n "${rr}p" $file_resultV`
		set isi = `sed -n "${rr}p" $file_result`
		set y = `sed -n "${rr}p" $file_resultY`
		set c = `sed -n "${rr}p" $file_resultC`
	
		set num_trials = $#y
		foreach i (`count -digit 1 1 $num_trials`)
			@ before = $i * 2 - 1
			@ after = $i * 2
			echo -n $v[$before] $isi[$before] $v[$after] $isi[$after] $y[$i] $c[$i]' '  >> $file_resultVWMR
		end
		echo '' >> $file_resultVWMR
	end
	################################################
	echo "done for $subj"
end

