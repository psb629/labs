#!/bin/zsh

## ============================================================ ##
do_scale=true

## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-s | --subject)
			subj="$2"
		;;
		-p | --phase)
			phase="$2"
		;;
		-d | --do_scale)
			if [[ ($2 == 'y') || ($2 == 'yes') ]]; then
				do_scale=true
			elif [[ ($2 == 'n') || ($2 == 'no') ]]; then
				do_scale=false
			fi
		;;
	esac
	shift ##takes one argument
done

## ============================================================ ##

dir_root=`find /mnt/ext5/SMC/fmri_data/raw_data/$phase -maxdepth 1 -type d -name "$subj*"`

dir_output=$dir_root/tmp
if [[ ! -d $dir_output ]]; then
	mkdir -p -m 755 $dir_output
fi

## ============================================================ ##
## T1
dir_raw=`find $dir_root -maxdepth 1 -type d \( -name "$subj_*_T1" -o -name "$subj_*_t1" -o -name "t1" \)`
if [[ -d $dir_raw ]]; then
	dcm2niix_afni -o $dir_output -s y -f $subj.T1 $dir_raw
else
	fname=`find $dir_root -type f -name "S??_*_T1.PAR"`
	print $fname
	dcm2niix_afni -o $dir_output -s y -f $subj.T1 $fname
fi

### scaling
if [[ $do_scale = true ]]; then
	3dcalc -a $dir_output/$subj.T1.nii -expr "a*0.01" -prefix $dir_root/$subj.T1.nii
else
 	cp $dir_output/$subj.T1.nii $dir_root
fi
cp $dir_output/$subj.T1.json $dir_root

rm -rf $dir_output/$subj.T1.*
## ============================================================ ##
## fMRI
dir_raw=`find $dir_root -mindepth 1 -type d \( -name "$subj_*_fMRI" -o -name "$subj_*_FMRI" -o -name "$subj_*_fmri" -o -name "epi" \)`
if [[ -d $dir_raw ]]; then
	# Note, 일반적으로 DICOM 파일은 t 시간때의 volume(3D) 정보를 담은 하나의 파일로 생성되는거 같음.
	# 따라서  dcm2niix 프로그램도 dcm 파일의 index를 시간순서로만 이해하고 실행됨.
	# 그러나 SMC의 경우, 첫 300개의 파일(1~300)은 첫번째 slice(2D)의 시간순(300장)을 의미하고, 두번째 300개의 파일은 (301~601) 두번째 slice(2D)의 시간순(300장)을 의미함. 따라서 이것을 t=1일때 slices (61장), t=2일때 slices(60장)으로 재배열하면 dcm2niix가 알아서 2D slices을 먼저 묶고(3D) 시간순으로 합성하여 (3+1)D NIFTI 파일로 변환함.
	if [[ -f $dir_raw/$subj.dcm00001.dcm ]]; then
		gg='%05g'
	else
		gg='%04g'
	fi
	ii=1
	for time in `seq 1 300`
	{
		for slice in `seq -f $gg $time 300 18001`
		{
			jj=`printf %05d $ii`
			cp $dir_raw/$subj.dcm$slice.dcm $dir_output/$jj.dcm
		 	(( ii = $ii + 1 ))
		}
	}
	
	dcm2niix_afni -o $dir_root -s y -f $subj.func $dir_output
else
	# Note, PAR 파일은 dcm2niix 변환시, dt=2000ms 간격으로 volume(3D) 정보를 담은 파일들을 300개 생성함.
	# 그러므로 이 300개의 volume 을 TR=2000ms 간격으로 3dTcat 을 하면 완료.
	fname=`find $dir_root -type f -name "S??_*_FMRI.PAR"`
	dcm2niix_afni -o $dir_output -s y -f $subj.func $fname
	mv $dir_output/$subj.func.json $dir_output/$subj.func_t0000.json
	mv $dir_output/$subj.func.nii $dir_output/$subj.func_t0000.nii
	
	for t in `seq -f "%04g" 0 2000 598000`
	{
		from=$dir_output/$subj.func_t$t.nii
		if [[ ! -f $from  ]]; then
			continue
		elif [[ -f $to ]]; then
			continue
		fi
		t_new=`printf %06d $t`
		to=$dir_output/$subj.func_t$t_new.nii
		mv $from $to
	}
	3dTcat -tr 2 -prefix $dir_root/$subj.func.nii $dir_output/$subj.func_t*.nii
fi
## ============================================================ ##
rm -rf $dir_output
