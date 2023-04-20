#!/bin/zsh

##############################################################
## default
ROI=false
RGS=false
frac=0.7
##############################################################
## Valid participants list
list_nn=(\
	12 17 18 19 20\
	22 24 25 27 31\
	32 33 36 37 38\
	40 43 46 47 48\
	)
##############################################################
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-f | --frac)
			frac="$2"
		;;
		-R | --ROI)
			ROI="$2"
		;;
		-G | --RemoveGlobalSignal)
			G_bool=$2
			if [[ ($2 == 'y') || ($2 == 'yes') ]]; then
				RGS=true
			elif [[ ($2 == 'n') || ($2 == 'no') ]]; then
				RGS=false
			fi
		;;
	esac
	shift ##takes one argument
done
##############################################################
dir_root="/mnt/ext5/SMC"

dir_behav="$dir_root/behav_data"

dir_fmri="$dir_root/fmri_data"
dir_stat="$dir_fmri/stats/correlations/$ROI"
dir_mask="$dir_fmri/masks"
##############################################################
mask="$dir_mask/mask.group.n56.frac=0.7.nii"
##############################################################
if [ ! -d $dir_stat ]; then
	print " invalid ROI (ROI name: $ROI)"
	exit
fi
##############################################################
## Behavioral improvement data
list_1D=(`find $dir_behav -type f -name "*.txt"`)
##############################################################
## Make a bucket file
pname="$dir_stat/bucket.$ROI.n${#list_fname}.post-pre.GlobalSignalRemoved=$RGS.nii"
if [ ! -f $pname ]; then
	list_fname=()
	for nn in $list_nn
	{
		list_fname=($list_fname "$dir_stat/3dTcorr1D.$ROI.S$nn.post-pre.GlobalSignalRemoved=$RGS.nii")
	}
	3dbucket	\
		-fbuc	\
		-prefix $pname	\
		$list_fname
fi
bucket=$pname
##############################################################
## Calculate Pearson correlation between behavioral data and functional data
for behav in $list_1D
{
	sname=${behav[$#dir_behav+2,-5]}
	3dTcorr1D	\
		-mask $mask	\
		-prefix "$dir_stat/3dTcorr1D.$ROI.$sname.GlobalSignalRemoved=$RGS.nii"	\
		$bucket $behav
}
