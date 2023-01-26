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
list_dlpfc=( \
	09 10 18 21 22 24 \
	27 34 35 36 38 42 \
	57 59 62		  \
	)
list_m1=( \
	08 11 17 19 20 26 \
	32 33 37 39 40 41 \
	56 58 61		  \
	)
list_20=( \
	43 44 45 46 47 48 \
	49 50 51 53 54 55 \
	)
## ============================================================ ##
dir_root="/mnt/ext5/GP"
stat="${time_shift}s_shifted"

dir_fmri="$dir_root/fmri_data"
dir_mask="$dir_fmri/masks"
dir_stat="$dir_fmri/stats/AM/3dREMLfit.reward_per_trial/$stat"

dir_output=$dir_stat
## ============================================================ ##
mask="$dir_mask/mask.group.day2.n42.frac=0.7.nii"
## ============================================================ ##
cd $dir_output

 #list_nn=($list_20)
 #setA=()
 #for nn in $list_nn
 #{
 #	subj="GP$nn"
 #	setA=($setA "$nn \$dir_stat/$subj/funcR.Rew.$subj.nii'[Rew#1_Coef]' \$dir_stat/$subj/funcR.Rew.$subj.nii'[Rew#1_Tstat]' \\ \n")
 #}
 #print $setA

## DLPFC (dlpfc)
3dMEMA	\
	-mask $mask	\
	-set Rew	\
	09 $dir_stat/GP09/funcR.Rew.GP09.nii'[Rew#1_Coef]' $dir_stat/GP09/funcR.Rew.GP09.nii'[Rew#1_Tstat]'	\
	10 $dir_stat/GP10/funcR.Rew.GP10.nii'[Rew#1_Coef]' $dir_stat/GP10/funcR.Rew.GP10.nii'[Rew#1_Tstat]'	\
	18 $dir_stat/GP18/funcR.Rew.GP18.nii'[Rew#1_Coef]' $dir_stat/GP18/funcR.Rew.GP18.nii'[Rew#1_Tstat]'	\
	21 $dir_stat/GP21/funcR.Rew.GP21.nii'[Rew#1_Coef]' $dir_stat/GP21/funcR.Rew.GP21.nii'[Rew#1_Tstat]'	\
	22 $dir_stat/GP22/funcR.Rew.GP22.nii'[Rew#1_Coef]' $dir_stat/GP22/funcR.Rew.GP22.nii'[Rew#1_Tstat]'	\
	24 $dir_stat/GP24/funcR.Rew.GP24.nii'[Rew#1_Coef]' $dir_stat/GP24/funcR.Rew.GP24.nii'[Rew#1_Tstat]'	\
	27 $dir_stat/GP27/funcR.Rew.GP27.nii'[Rew#1_Coef]' $dir_stat/GP27/funcR.Rew.GP27.nii'[Rew#1_Tstat]'	\
	34 $dir_stat/GP34/funcR.Rew.GP34.nii'[Rew#1_Coef]' $dir_stat/GP34/funcR.Rew.GP34.nii'[Rew#1_Tstat]'	\
	35 $dir_stat/GP35/funcR.Rew.GP35.nii'[Rew#1_Coef]' $dir_stat/GP35/funcR.Rew.GP35.nii'[Rew#1_Tstat]'	\
	36 $dir_stat/GP36/funcR.Rew.GP36.nii'[Rew#1_Coef]' $dir_stat/GP36/funcR.Rew.GP36.nii'[Rew#1_Tstat]'	\
	38 $dir_stat/GP38/funcR.Rew.GP38.nii'[Rew#1_Coef]' $dir_stat/GP38/funcR.Rew.GP38.nii'[Rew#1_Tstat]'	\
	42 $dir_stat/GP42/funcR.Rew.GP42.nii'[Rew#1_Coef]' $dir_stat/GP42/funcR.Rew.GP42.nii'[Rew#1_Tstat]'	\
	57 $dir_stat/GP57/funcR.Rew.GP57.nii'[Rew#1_Coef]' $dir_stat/GP57/funcR.Rew.GP57.nii'[Rew#1_Tstat]'	\
	59 $dir_stat/GP59/funcR.Rew.GP59.nii'[Rew#1_Coef]' $dir_stat/GP59/funcR.Rew.GP59.nii'[Rew#1_Tstat]'	\
	62 $dir_stat/GP62/funcR.Rew.GP62.nii'[Rew#1_Coef]' $dir_stat/GP62/funcR.Rew.GP62.nii'[Rew#1_Tstat]'	\
	-prefix GP.dlPFC_cTBS.n$#list_dlpfc.nii	\
	-missing_data 0	\
	-HKtest	\
	-model_outliers	\
	-residual_Z

## m1
3dMEMA	\
	-mask $mask	\
	-set Rew	\
	08 $dir_stat/GP08/funcR.Rew.GP08.nii'[Rew#1_Coef]' $dir_stat/GP08/funcR.Rew.GP08.nii'[Rew#1_Tstat]'	\
	11 $dir_stat/GP11/funcR.Rew.GP11.nii'[Rew#1_Coef]' $dir_stat/GP11/funcR.Rew.GP11.nii'[Rew#1_Tstat]'	\
	17 $dir_stat/GP17/funcR.Rew.GP17.nii'[Rew#1_Coef]' $dir_stat/GP17/funcR.Rew.GP17.nii'[Rew#1_Tstat]'	\
	19 $dir_stat/GP19/funcR.Rew.GP19.nii'[Rew#1_Coef]' $dir_stat/GP19/funcR.Rew.GP19.nii'[Rew#1_Tstat]'	\
	20 $dir_stat/GP20/funcR.Rew.GP20.nii'[Rew#1_Coef]' $dir_stat/GP20/funcR.Rew.GP20.nii'[Rew#1_Tstat]'	\
	26 $dir_stat/GP26/funcR.Rew.GP26.nii'[Rew#1_Coef]' $dir_stat/GP26/funcR.Rew.GP26.nii'[Rew#1_Tstat]'	\
	32 $dir_stat/GP32/funcR.Rew.GP32.nii'[Rew#1_Coef]' $dir_stat/GP32/funcR.Rew.GP32.nii'[Rew#1_Tstat]'	\
	33 $dir_stat/GP33/funcR.Rew.GP33.nii'[Rew#1_Coef]' $dir_stat/GP33/funcR.Rew.GP33.nii'[Rew#1_Tstat]'	\
	37 $dir_stat/GP37/funcR.Rew.GP37.nii'[Rew#1_Coef]' $dir_stat/GP37/funcR.Rew.GP37.nii'[Rew#1_Tstat]'	\
	39 $dir_stat/GP39/funcR.Rew.GP39.nii'[Rew#1_Coef]' $dir_stat/GP39/funcR.Rew.GP39.nii'[Rew#1_Tstat]'	\
	40 $dir_stat/GP40/funcR.Rew.GP40.nii'[Rew#1_Coef]' $dir_stat/GP40/funcR.Rew.GP40.nii'[Rew#1_Tstat]'	\
	41 $dir_stat/GP41/funcR.Rew.GP41.nii'[Rew#1_Coef]' $dir_stat/GP41/funcR.Rew.GP41.nii'[Rew#1_Tstat]'	\
	56 $dir_stat/GP56/funcR.Rew.GP56.nii'[Rew#1_Coef]' $dir_stat/GP56/funcR.Rew.GP56.nii'[Rew#1_Tstat]'	\
	58 $dir_stat/GP58/funcR.Rew.GP58.nii'[Rew#1_Coef]' $dir_stat/GP58/funcR.Rew.GP58.nii'[Rew#1_Tstat]'	\
	61 $dir_stat/GP61/funcR.Rew.GP61.nii'[Rew#1_Coef]' $dir_stat/GP61/funcR.Rew.GP61.nii'[Rew#1_Tstat]'	\
	-prefix GP.m1_cTBS.n$#list_m1.nii	\
	-missing_data 0	\
	-HKtest	\
	-model_outliers	\
	-residual_Z

## DLPFC (20Hz)
3dMEMA	\
	-mask $mask	\
	-set Rew	\
	43 $dir_stat/GP43/funcR.Rew.GP43.nii'[Rew#1_Coef]' $dir_stat/GP43/funcR.Rew.GP43.nii'[Rew#1_Tstat]'	\
	44 $dir_stat/GP44/funcR.Rew.GP44.nii'[Rew#1_Coef]' $dir_stat/GP44/funcR.Rew.GP44.nii'[Rew#1_Tstat]'	\
	45 $dir_stat/GP45/funcR.Rew.GP45.nii'[Rew#1_Coef]' $dir_stat/GP45/funcR.Rew.GP45.nii'[Rew#1_Tstat]'	\
	46 $dir_stat/GP46/funcR.Rew.GP46.nii'[Rew#1_Coef]' $dir_stat/GP46/funcR.Rew.GP46.nii'[Rew#1_Tstat]'	\
	47 $dir_stat/GP47/funcR.Rew.GP47.nii'[Rew#1_Coef]' $dir_stat/GP47/funcR.Rew.GP47.nii'[Rew#1_Tstat]'	\
	48 $dir_stat/GP48/funcR.Rew.GP48.nii'[Rew#1_Coef]' $dir_stat/GP48/funcR.Rew.GP48.nii'[Rew#1_Tstat]'	\
	49 $dir_stat/GP49/funcR.Rew.GP49.nii'[Rew#1_Coef]' $dir_stat/GP49/funcR.Rew.GP49.nii'[Rew#1_Tstat]'	\
	50 $dir_stat/GP50/funcR.Rew.GP50.nii'[Rew#1_Coef]' $dir_stat/GP50/funcR.Rew.GP50.nii'[Rew#1_Tstat]'	\
	51 $dir_stat/GP51/funcR.Rew.GP51.nii'[Rew#1_Coef]' $dir_stat/GP51/funcR.Rew.GP51.nii'[Rew#1_Tstat]'	\
	53 $dir_stat/GP53/funcR.Rew.GP53.nii'[Rew#1_Coef]' $dir_stat/GP53/funcR.Rew.GP53.nii'[Rew#1_Tstat]'	\
	54 $dir_stat/GP54/funcR.Rew.GP54.nii'[Rew#1_Coef]' $dir_stat/GP54/funcR.Rew.GP54.nii'[Rew#1_Tstat]'	\
	55 $dir_stat/GP55/funcR.Rew.GP55.nii'[Rew#1_Coef]' $dir_stat/GP55/funcR.Rew.GP55.nii'[Rew#1_Tstat]'	\
	-prefix GP.dlPFC_20Hz.n$#list_20.nii	\
	-missing_data 0	\
	-HKtest	\
	-model_outliers	\
	-residual_Z
## ============================================================ ##
## extract the Z stat
3dcalc -a GP.dlPFC_cTBS.n$#list_dlpfc.nii'[Rew:t]' -expr 'a' -prefix GP.dlPFC_cTBS.tval.n$#list_dlpfc.nii
3dcalc -a GP.m1_cTBS.n$#list_m1.nii'[Rew:t]' -expr 'a' -prefix GP.M1_cTBS.tval.n$#list_m1.nii
3dcalc -a GP.dlPFC_20Hz.n$#list_20.nii'[Rew:t]' -expr 'a' -prefix GP.dlPFC_20Hz.tval.n$#list_20.nii
## ============================================================ ##
 ### Two-sample test
 #3dMEMA	\
 #	-mask $mask	\
 #	-group M1 DLPFC_cTBS \
 #	-set Rew	\
 #		 $setA	\
 #	-prefix GP.dlPFC_cTBS-M1_cTBS.nii	\
 #	-model_outliers	\
 #	-residual_Z
