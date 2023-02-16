#!/bin/zsh

## ============================================================ ##
## default
time_shift=0
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
	esac
	shift ##takes one argument
done
tmp=`printf "%.1f\n" $time_shift`
time_shift=$tmp
## ============================================================ ##
dir_root=/mnt/ext5/GA

dir_reg=$dir_root/behav_data/regressors/IM/4targets

dir_fmri=$dir_root/fmri_data
dir_stat=$dir_fmri/stats/IM/GLM.4targets/$subj
dir_preproc=$dir_fmri/preproc_data/$subj

dir_output=$dir_stat/betamap
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
line=1
for run in 'r01' 'r02' 'r03'
{
	cd $dir_stat

	start=$line
	end=$(($line+1095))

	sed -n -e "${start},${end}p" $dir_preproc/"motion_demean.1D" >$dir_stat/"head.$run.txt"
	sed -n -e "${start},${end}p" $dir_preproc/"motion_${subj}_censor.1D" >$dir_stat/"censor.$run.txt"
	sed -n -e "${run[-2,-1]}p" $dir_reg/"$subj.4targets.practice.txt" >$dir_stat/"stim.$run.txt"

	3dDeconvolve																\
		-input $dir_preproc/"pb0?.$subj.$run.scale+tlrc.HEAD"					\
		-polort A -float -allzero_OK											\
		-censor $dir_stat/"censor.$run.txt"										\
		-mask $dir_preproc/"full_mask.$subj+tlrc.HEAD"							\
	    -ortvec $dir_stat/"head.$run.txt" "head_motion"							\
		-num_stimts 1															\
		-stim_label 1 '4targets'												\
		-stim_times_IM 1 $dir_stat/"stim.$run.txt" 'BLOCK(5)'					\
		-x1D "X.xmat.$subj.$run.practice.1D" -xjpeg "X.$subj.$run.practice.jpg"	\
		-x1D_stop
	 #	-bucket "stats.4targets.$subj.nii"
	
	cd $dir_output
	3dLSS														\
		-verb													\
		-input $dir_preproc/"pb0?.$subj.$run.scale+tlrc.HEAD"	\
		-mask $dir_preproc/"full_mask.$subj+tlrc.HEAD"			\
		-matrix $dir_stat/"X.xmat.$subj.$run.practice.1D"		\
		-save1D "X.betas.LSS.$subj.$run.practice.1D"			\
		-prefix "betamap.$subj.$run.practice.nii"

	line=$(($line+1096))
}
