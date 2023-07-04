#!/bin/zsh

## ======================================= ##
## default
ROI=false
frac=0.7
mm='full'
## ======================================= ##
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
		;;
		-m | --mask)
			mm="$2"

	esac
	shift ##takes one argument
done
## ======================================= ##
dir_script="/home/sungbeenpark/Github/labs/SMC/scripts"

dir_root="/mnt/ext5/SMC/fmri_data"
dir_stat="$dir_root/stats/correlations/$ROI"
dir_mask="$dir_root/masks"
## ======================================= ##
case $G_bool in
	'y' | 'yes')
		GSR=true
	;;
	*)
		GSR=false
	;;
esac
## ======================================= ##
case $mm in
	'full' | 'Full')
		mask="$dir_mask/mask.group.n56.frac=$frac.nii"
	;;
	'precuneus' | 'Precuneus')
 #		mask="$dir_mask/mask.Harvard-Oxford.precuneus.nii"
 #		mask="$dir_mask/mask.Precuneus_z_3.29.nii"
		mask="$dir_root/stats/SSKim/mask.Prec.z7.nii"
	;;
esac
## ======================================= ##
## intersection(post & pre)
list_pre=(`ls $dir_stat/3dmaskave.$ROI.S??.pre.GlobalSignalRemoved=$GSR.t298.1D | grep -oP "S[0-9][0-9]" | sort`)
list_post=(`ls $dir_stat/3dmaskave.$ROI.S??.post.GlobalSignalRemoved=$GSR.t298.1D | grep -oP "S[0-9][0-9]" | sort`)
list_subj=(`comm -12 <(printf '%s\n' $list_pre[@]) <(printf '%s\n' $list_post[@])`)
print "list_subj(n$#list_subj): $list_subj"

## post - pre
cd $dir_stat
for subj in $list_subj
{
	pname="3dTcorr1D.$ROI.$subj.post-pre.GlobalSignalRemoved=$GSR.Fisher.nii"
	if [ ! -f $pname ]; then
		3dcalc \
			-a 3dTcorr1D.$ROI.$subj.post.GlobalSignalRemoved=$GSR.Fisher.nii	\
			-b 3dTcorr1D.$ROI.$subj.pre.GlobalSignalRemoved=$GSR.Fisher.nii		\
			-expr 'a-b'													\
			-prefix $pname
	fi
}
## ======================================= ##
## divide it by group
tmp=(`$dir_script/print.group.py --dir_fmri $dir_root --ROI $ROI --GSR $GSR --group 'sham'`)
list_sham=(`comm -12 <(printf '%s\n' $list_subj[@]) <(printf '%s\n' $tmp[@])`)
tmp=(`$dir_script/print.group.py --dir_fmri $dir_root --ROI $ROI --GSR $GSR --group 'stim'`)
list_stim=(`comm -12 <(printf '%s\n' $list_subj[@]) <(printf '%s\n' $tmp[@])`)
printf 'sham: %s\n' "$list_sham"
printf 'stim: %s\n' "$list_stim"
## ======================================= ##
## stim
setA=()
for subj in $list_stim
{
	setA+=("$dir_stat/3dTcorr1D.$ROI.$subj.post-pre.GlobalSignalRemoved=$GSR.Fisher.nii")
}
## sham
setB=()
for subj in $list_sham
{
	setB+=("$dir_stat/3dTcorr1D.$ROI.$subj.post-pre.GlobalSignalRemoved=$GSR.Fisher.nii")
}
## ======================================= ##
## T-test
pname="3dttest++.3dTcorr1D.group.post-pre.stim_n${#list_stim}-sham_n${#list_sham}.$ROI.mask=$mm.GlobalSignalRemoved=$GSR.Fisher.nii"
cd $dir_stat
3dttest++	\
	-mask $mask	\
	-setA $setA	\
	-setB $setB	\
	-prefix $pname	\
	-ClustSim 4
