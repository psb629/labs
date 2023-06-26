#!/bin/zsh

## ============================================================ ##
## default
tt=0
## ============================================================ ##
while (( $# )); do
	key="$1"
	case $key in
		-s | --subject)
			subj="$2"
		;;
		-t | --time_shift)
			tt="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
time_shift=`printf "%1.1f" $tt`
## ============================================================ ##
dir_root="/mnt/ext5/DRN"

dir_behav="$dir_root/behav_data"
dir_reg="$dir_behav/regressors/AM/value"

dir_fmri="$dir_root/fmri_data"
dir_preproc="$dir_fmri/preproc_data/$subj"
## ============================================================ ##
dir_output="$dir_fmri/stats/GLM/AM/value_function/shift=${time_shift}s/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
## concatenating regressors
reg=$dir_output/reg.txt
if [[ ! -f $reg ]]; then
	for run in `seq -f 'r%02g' 1 6`
	{
		fname="$dir_reg/$subj.$run.value.shift=${time_shift}s.txt"
		if [[ ! -f $fname ]]; then
			continue
		fi
		cat $fname >> $reg
		echo "" >> $reg
	}
fi
## ============================================================ ##
cd $dir_output
3dDeconvolve	\
	-input		$dir_preproc/pb0?.$subj.r0?.scale+tlrc.HEAD	\
	-mask		$dir_preproc/full_mask.$subj+tlrc.HEAD		\
    -censor		$dir_preproc/censor_${subj}_combined_2.1D	\
    -ortvec		$dir_preproc/ROIPC.FSvent.r01.1D ROIPC.FSvent.r01	\
    -ortvec		$dir_preproc/ROIPC.FSvent.r02.1D ROIPC.FSvent.r02	\
    -ortvec		$dir_preproc/ROIPC.FSvent.r03.1D ROIPC.FSvent.r03	\
    -ortvec		$dir_preproc/ROIPC.FSvent.r04.1D ROIPC.FSvent.r04	\
    -ortvec		$dir_preproc/ROIPC.FSvent.r05.1D ROIPC.FSvent.r05	\
    -ortvec		$dir_preproc/ROIPC.FSvent.r06.1D ROIPC.FSvent.r06	\
    -ortvec		$dir_preproc/mot_demean.r01.1D mot_demean_r01		\
    -ortvec		$dir_preproc/mot_demean.r02.1D mot_demean_r02		\
    -ortvec		$dir_preproc/mot_demean.r03.1D mot_demean_r03		\
    -ortvec		$dir_preproc/mot_demean.r04.1D mot_demean_r04		\
    -ortvec		$dir_preproc/mot_demean.r05.1D mot_demean_r05		\
    -ortvec		$dir_preproc/mot_demean.r06.1D mot_demean_r06		\
    -polort		5	\
	-float		\
	-allzero_OK	\
	-num_stimts	1	\
	-stim_times_AM2	1 $reg 'BLOCK(1,1)' -stim_label 1 'Val'	\
	-jobs 1 -fout -tout	\
	-x1D "X.xmat.1D"	-xjpeg "X.jpg"	\
	-x1D_uncensored "X.nocensor.xmat.1D"\
	-bucket stats.$subj.nii
 #    -fitts fitts.$subj.nii
 #    -errts errts.$subj.nii

echo " Calculating GLM for subject $subj completed"
