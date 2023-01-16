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
list_sham=(`$dir_script/print.group.py -R $ROI -G $G_bool -g 'sham'`)
list_stim=(`$dir_script/print.group.py -R $ROI -G $G_bool -g 'stim'`)
##############################################################
## sham
pre_sham=()
for nn in $list_sham
{
	subj="S$nn"
	pre_sham=($pre_sham "$dir_stat/3dTcorr1D.$ROI.$subj.pre.GlobalSignalRemoved=$RGS.nii")
}
post_sham=()
for nn in $list_sham
{
	subj="S$nn"
	post_sham=($post_sham "$dir_stat/3dTcorr1D.$ROI.$subj.post.GlobalSignalRemoved=$RGS.nii")
}
## stim
pre_stim=()
for nn in $list_stim
{
	subj="S$nn"
	pre_stim=($pre_stim "$dir_stat/3dTcorr1D.$ROI.$subj.pre.GlobalSignalRemoved=$RGS.nii")
}
post_stim=()
for nn in $list_stim
{
	subj="S$nn"
	post_stim=($post_stim "$dir_stat/3dTcorr1D.$ROI.$subj.post.GlobalSignalRemoved=$RGS.nii")
}
##############################################################
cd $dir_stat
## sham
3dttest++ -mask "$dir_mask/mask.group.n56.frac=$frac.nii"										\
	-setA $post_sham																			\
	-setB $pre_sham																				\
	-paired																						\
	-prefix "SMC.3dTcorr1D.group.sham.n$#list_sham.post-pre.$ROI.GlobalSignalRemoved=$RGS.nii"	\
	-ClustSim 4
## stim
3dttest++ -mask "$dir_mask/mask.group.n56.frac=$frac.nii"										\
	-setA $post_stim																			\
	-setB $pre_stim																				\
	-paired																						\
	-prefix "SMC.3dTcorr1D.group.stim.n$#list_stim.post-pre.$ROI.GlobalSignalRemoved=$RGS.nii"	\
	-ClustSim 4
## stim - sham
3dttest++ -mask "$dir_mask/mask.group.n56.frac=$frac.nii"										\
	-setA $post_stim																			\
	-setB $post_sham																			\
	-prefix "SMC.3dTcorr1D.group.post.stim-sham.$ROI.GlobalSignalRemoved=$RGS.nii"				\
	-ClustSim 4
