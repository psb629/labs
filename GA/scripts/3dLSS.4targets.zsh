#!/bin/zsh

## ============================================================ ##
## default
time_shift=0
list_run=('r01' 'r02' 'r03')
## ============================================================ ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-s | --subject)
			## string
			subj="$2"
		;;
		-t | --time_shift)
			## string
			time_shift="$2"
		;;
		-p | --phase)
			case $2 in
				1 | 'prac' | 'practice')
					phase='prac'
				;;
				2 | 'unprac' | 'unpractice')
					phase='unprac'
				;;
				*)
					phase=false
				;;
			esac
		;;
		-GSR | --global_signal_regression)
			case $2 in
				'y' | 'yes')
					GSR=true
				;;
				*)
					GSR=false
				;;
			esac
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
tmp=`printf "%.1f\n" $time_shift`
time_shift=$tmp

if [ $phase = false ]; then
	exit
fi
## ============================================================ ##
dir_root="/mnt/ext5/GA"

dir_reg="$dir_root/behav_data/regressors/IM/4targets"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj/$phase"
dir_stat="$dir_fmri/stats/IM/GLM.4targets/$subj/$phase"
## ============================================================ ##
dir_output="$dir_stat/betamap"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
line=1
for run in $list_run
{

	start=$line
	end=$(($line+1095))

	cd $dir_stat
	sed -n -e "${start},${end}p" $dir_preproc/"motion_demean.1D" >"head.$run.$phase.txt"
	sed -n -e "${start},${end}p" $dir_preproc/"motion_${subj}_censor.1D" >"censor.$run.$phase.txt"
	sed -n -e "${run[-2,-1]}p" $dir_reg/"$subj.4targets.${phase}tice.txt" >"stim.$run.$phase.txt"

	if [[ $GSR = true ]]; then
	{
		tsmean_GS=$dir_preproc/"$subj.global_signal.whole_brain.1D"
		if [ ! -f $tsmean_GS ];then
			/home/sungbeenpark/Github/labs/GA/scripts/extract.global_signal.zsh -s $subj -p $phase
		fi
		3dDeconvolve																				\
			-input $dir_preproc/"pb0?.$subj.$run.scale+tlrc.HEAD"									\
			-polort A -float -allzero_OK															\
			-censor $dir_stat/"censor.$run.$phase.txt"												\
			-mask $dir_preproc/"full_mask.$subj+tlrc.HEAD"											\
		    -ortvec $dir_stat/"head.$run.$phase.txt" "head_motion"									\
		    -ortvec $tsmean_GS 'GS'																	\
			-num_stimts 1																			\
			-stim_label 1 '4targets'																\
			-stim_times_IM 1 $dir_stat/"stim.$run.$phase.txt" 'BLOCK(5)'							\
			-x1D "X.xmat.$subj.$run.$phase.GSR=$GSR.1D" -xjpeg "X.$subj.$run.$phase.GSR=$GSR.jpg"	\
			-x1D_stop
		 #	-bucket "stats.4targets.$subj.nii"
	}
	else
	{
		3dDeconvolve																				\
			-input $dir_preproc/"pb0?.$subj.$run.scale+tlrc.HEAD"									\
			-polort A -float -allzero_OK															\
			-censor $dir_stat/"censor.$run.$phase.txt"												\
			-mask $dir_preproc/"full_mask.$subj+tlrc.HEAD"											\
		    -ortvec $dir_stat/"head.$run.$phase.txt" "head_motion"									\
			-num_stimts 1																			\
			-stim_label 1 '4targets'																\
			-stim_times_IM 1 $dir_stat/"stim.$run.$phase.txt" 'BLOCK(5)'							\
			-x1D "X.xmat.$subj.$run.$phase.GSR=$GSR.1D" -xjpeg "X.$subj.$run.$phase.GSR=$GSR.jpg"	\
			-x1D_stop
		 #	-bucket "stats.4targets.$subj.nii"
	}
	fi

	cd $dir_output
	3dLSS														\
		-verb													\
		-input $dir_preproc/"pb0?.$subj.$run.scale+tlrc.HEAD"	\
		-mask $dir_preproc/"full_mask.$subj+tlrc.HEAD"			\
		-matrix $dir_stat/"X.xmat.$subj.$run.$phase.GSR=$GSR.1D"\
		-save1D "X.betas.LSS.$subj.$run.$phase.GSR=$GSR.1D"		\
		-prefix "betamap.$subj.$run.$phase.GSR=$GSR.nii"

	line=$(($line+1096))
}
