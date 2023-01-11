#!/bin/zsh

##############################################################
## default
ROI=false
RGS=false
frac=0.7
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
dir_script="/home/sungbeenpark/Github/labs/Samsung_Hospital/scripts"

dir_root="/mnt/ext5/SMC/fmri_data"
dir_stat="$dir_root/stats/correlations/$ROI"
dir_mask="$dir_root/masks"
##############################################################
list_subj=(`$dir_script/find.common_elements.py -R $ROI -G $G_bool`)
##############################################################
pre=()
for subj in $list_subj
{
	pre=($pre "$dir_stat/3dTcorr1D.$ROI.$subj.pre.GlobalSignalRemoved=$RGS.nii")
}

post=()
for subj in $list_subj
{
	post=($post "$dir_stat/3dTcorr1D.$ROI.$subj.post.GlobalSignalRemoved=$RGS.nii")
}
##############################################################
cd $dir_stat
3dttest++ -mask "$dir_mask/mask.group.n56.frac=$frac.nii"									\
	-setA $post																				\
	-setB $pre																				\
	-paired																					\
	-prefix "SMC.group.n$#list_subj.3dTcorr1D.post-pre.$ROI.GlobalSignalRemoved=$RGS.nii"	\
	-ClustSim 4
