#!/bin/tcsh

set subj = TML04_PILOT
set var2 = (`echo $subj | cut -c3`)
echo $subj $var2

set check = `ls ./3dDeconvolve | grep 'GLM2'`
if ( -e ./3dDeconvolve/$check ) then
	echo oo
endif

#set run = r02
#sed -n "`echo $run | cut -c3`p" /clmnlab/TM/behav_data/regressors/Reg1/TML03_PILOT/*.txt > temp.txt

set word1 = bbb
echo $word1
set word1 = aaa.$word1
echo $word1

set num1 = 1
@ num2 = $num1 * 10
echo $num1 $num2
###############################################################
set subj = TML04_PILOT
set cf = '15.0'
set order = `column -c 1 /clmnlab/TM/behav_data/$subj/{$subj}.Dis_freq_order.dat`
set tempC = /clmnlab/TM/tempC.dat
set tempO = /clmnlab/TM/tempO.dat
set tempY = /clmnlab/TM/tempY.dat
set onsets_V = ()
set onsets_Y = ()
foreach run (1 2 3)
	set onsets_V = ($onsets_V `sed -n {$run}p /clmnlab/TM/behav_data/regressors/$subj/onset_vibration.dat`)
	set onsets_Y = ($onsets_Y `sed -n {$run}p /clmnlab/TM/behav_data/regressors/$subj/onset_yellow.dat`)
end
echo "order($#order) :" $order
echo "onsets_V($#onsets_V) :" $onsets_V
echo "onsets_V[1] = $onsets_V[1], onsets_V[2] = $onsets_V[2], ..., onsets_V[200] = $onsets_V[200]"
echo "onsets_Y($#onsets_Y) :" $onsets_Y

if (-e $tempC) then
	rm $tempC
endif
if (-e $tempO) then
	rm $tempO
endif
if (-e $tempY) then
	rm $tempY
endif

foreach trial (`count -digit 1 1 100`)
	@ idx_before = $trial * 2 - 1
	@ idx_after = $trial * 2
	if ($order[$idx_before] == $cf) then
		echo -n $onsets_V[$idx_before]' ' >> $tempC
		echo -n $onsets_V[$idx_after]' ' >> $tempO
	else if ($order[$idx_after] == $cf) then
		echo -n $onsets_V[$idx_after]' ' >> $tempC
		echo -n $onsets_V[$idx_before]' ' >> $tempO
	else
		echo "error : trial = $trial, order[$idx_before] = $order[$idx_before], order[$idx_after] = $order[$idx_after]"
	endif
	echo -n $onsets_Y[$trial]' ' >> $tempY
	if ($trial == 40) then
		echo '' >> $tempC
		echo '' >> $tempO
		echo '' >> $tempY
	else if ($trial == 70) then
		echo '' >> $tempC
		echo '' >> $tempO
		echo '' >> $tempY
	endif
	rm $tempC $tempO $tempY
end
###############################################################
set x = -1
switch ($x)
case 1:
	echo "x=1"
	breaksw
case -1:
	echo "x=-1"
	breaksw
default:
	echo "|x|!=1"
endsw
###############################################################
set subj_list = (\
				TML14 TML15 TML16 TML18 TML19 TML20\
				TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29\
				)
 #foreach subj ($subj_list)
 #	set temp = /clmnlab/TM/fMRI_data/preproc_data/$subj/preprocessed/full_mask.$subj.nii.gz
 #	cp $temp /clmnlab/TM/fMRI_data/masks/full_masks/
 #end
###############################################################
set subj = KJW
set preproc_dir = /clmnlab/TM/fMRI_data/preproc_data
set subj_preproc_dir = $preproc_dir/$subj/preprocessed
set subj_fullmask = $subj_preproc_dir/full_mask.{$subj}+tlrc
set pref = $subj_preproc_dir/full_mask.{$subj}.nii.gz
if (! -e $pref) then
	3dAFNItoNIFTI -prefix $pref $subj_fullmask
endif
