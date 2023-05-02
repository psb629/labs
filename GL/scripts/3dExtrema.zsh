#!/bin/zsh

##############################################################
area=false
vv=false
##############################################################
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
		-a | --area)
			area="$2"
		;;
		-R | --ROI)
			ROI="$2"
		;;
		--pb )
			pp="$2"
		;;
	esac
	shift ##takes one argument
done
##############################################################
check=false
case $ROI in
	'caudate' | 'Caudate')
		check=true
		case $area in
			'la')
				vv=1
			;;
			'lp')
				vv=2
			;;
			'ra')
				vv=3
			;;
			'rp')
				vv=4
			;;
		esac
	;;
	'putamen' | 'Putamen')
		check=true
		case $area in
			'la')
				vv=1
			;;
			'lp')
				vv=3
			;;
			'ra')
				vv=2
			;;
			'rp')
				vv=4
			;;
		esac
		;;
esac
if [ $check = false ]; then
	print " You need to put a right value for an option -R."
	print " e.g.) -R caudate, -R putamen"
	exit
fi
if [ $vv = false ]; then
	print " You need to put a right value for an option -a."
	print " e.g.) -a la (left anterior), -a rp (right posterior)"
	exit
fi
##############################################################
case $pp in
	04 | '04' | 'pb04')
		pb='scale'
	;;
	*)
		pb='volreg'
	;;
esac
##############################################################
dir_root="/mnt/ext4/GL/fmri_data"
dir_mask="$dir_root/masks"
dir_preproc="$dir_root/preproc_data.SSKim/$subj"
dir_stat="$dir_root/stats/GLM.reward.4s_shifted.SSKim/$subj"
dir_output=$dir_stat
##############################################################
## make temparal masks
mask=$dir_output/"mask.tmp.$ROI.$area.nii"
3dcalc												\
	-a $dir_mask/"mask.TTatlas.$ROI.resampled.nii"	\
	-expr "equals(a,$vv)"							\
	-prefix $mask									\

fname=$dir_stat/stats.$subj+tlrc.HEAD'[Rew#1_Tstat]'
pname=$dir_output/"mask.3dExtrema.$ROI.$area.$subj.nii"
3dExtrema						\
	-volume -closure			\
	-mask_file $mask			\
	-mask_thr 1					\
	-maxima						\
	-nbest 1					\
	-data_thr 0					\
	-sep_dist 512				\
	-prefix $pname				\
	$fname
rm $mask
mask=$pname
##############################################################
## extract the entire BOLD signal across all runs from the voxel
fname=$dir_preproc/"tproject.errts.$subj.$pb.r02_05.nii"
3dmaskave											\
	-quiet											\
	-mask $mask										\
	$fname >$dir_output/"ts.$ROI.$area.$subj.$pb.1D"
rm $mask
