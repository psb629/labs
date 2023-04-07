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
## intersection(post & pre)
list_subj=(`comm -1 -2 <(ls $dir_stat/3dmaskave.$ROI.S??.pre.GlobalSignalRemoved=$RGS.t298.1D | grep -P -o "S[0-9][0-9]") <(ls $dir_stat/3dmaskave.$ROI.S??.post.GlobalSignalRemoved=$RGS.t298.1D | grep -P -o "S[0-9][0-9]")`)
 #print $list_subj
 #
## post - pre
cd $dir_stat
for subj in $list_subj
{
	pname="3dTcorr1D.$ROI.$subj.post-pre.GlobalSignalRemoved=$RGS.nii"
	if [ ! -f $pname ]; then
		3dcalc \
			-a 3dTcorr1D.$ROI.$subj.post.GlobalSignalRemoved=$RGS.nii	\
			-b 3dTcorr1D.$ROI.$subj.pre.GlobalSignalRemoved=$RGS.nii	\
			-expr 'a-b'													\
			-prefix $pname
	fi
}

## divide it by group
tmp=(`$dir_script/print.group.py -R $ROI -G $G_bool -g 'sham'`)
list_sham=(`comm -12 <(printf '%s\n' "${list_subj[@]}") <(printf '%s\n' "${tmp[@]}")`)
tmp=(`$dir_script/print.group.py -R $ROI -G $G_bool -g 'stim'`)
list_stim=(`comm -12 <(printf '%s\n' "${list_subj[@]}") <(printf '%s\n' "${tmp[@]}")`)
 #printf 'sham: %s\n' "$list_sham"
 #printf 'stim: %s\n' "$list_stim"
##############################################################
##############################################################
## stim
setA=()
for subj in $list_stim
{
	setA+=("$dir_stat/3dTcorr1D.$ROI.$subj.post-pre.GlobalSignalRemoved=$RGS.nii")
}

## sham
setB=()
for subj in $list_sham
{
	setB+=("$dir_stat/3dTcorr1D.$ROI.$subj.post-pre.GlobalSignalRemoved=$RGS.nii")
}
##############################################################
## T test
cd $dir_stat
3dttest++ -mask "$dir_mask/mask.group.n56.frac=$frac.nii"								\
	-setA $setA																			\
	-setB $setB																			\
	-prefix "3dttest++.3dTcorr1D.group.post-pre.stim_n${#list_stim}-sham_n${#list_sham}.$ROI.GlobalSignalRemoved=$RGS.nii"		\
	-ClustSim 4
