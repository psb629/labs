#!/bin/zsh

list_DLPFC=('09' '10' '18' '21' '22' '24' '27' '34' '35' '36' '38' '42')
list_m1=('08' '11' '17' '19' '20' '26' '32' '33' '37' '39' '40' '41')
list_high=('43' '44' '45' '46' '47' '48' '49' '50' '51' '53' '54' '55')
# ============================================================
dir_root="/mnt/ext6/GP/fmri_data"
dir_stat="$dir_root/stats/AM/reward"
dir_mask="$dir_root/masks/"
# ============================================================
dir_output=$dir_stat
# ============================================================
 #list=(`ls $dir_stat/GP??/statsRWDtime.GP??.SPMG2+tlrc.HEAD`)
 #foreach fname ($list)
 #	subj=$fname[-20,-17]
 #	3dcalc -a $fname'[rwdtm#2_Coef]' -expr 'a' -prefix $dir_stat/$subj/rwdtm#2_Coef.$subj.nii
 #end
 #
## make group full mask
full_mask=$dir_mask/full_mask.GP.group.nii
if [ ! -f $full_mask ]; then
	list=()
	foreach nn ($list_DLPFC)
		subj="GP$nn"
		list=($list $dir_root/preproc_data/$subj/day2/preprocessed/full_mask.$subj+tlrc.HEAD)
	end
	foreach nn ($list_m1)
		subj="GP$nn"
		list=($list $dir_root/preproc_data/$subj/day2/preprocessed/full_mask.$subj+tlrc.HEAD)
	end
	foreach nn ($list_high)
		subj="GP$nn"
		list=($list $dir_root/preproc_data/$subj/day2/preprocessed/full_mask.$subj+tlrc.HEAD)
	end
	3dMean -mask_inter -prefix $full_mask $list
fi

## one-sample t-test
### DLPFC (Low)
list=()
foreach nn ($list_DLPFC)
	subj="GP$nn"
	list=($list $dir_stat/$subj/statsRWDtime.$subj.SPMG2+tlrc.HEAD'[rwdtm#2_Coef]')
end
3dttest++ -prefix $dir_output/rwdtm#2_Coef.group.DLPFC_low.nii -setA $list -mask $full_mask -toz

### M1
list=()
foreach nn ($list_m1)
	subj="GP$nn"
	list=($list $dir_stat/$subj/statsRWDtime.$subj.SPMG2+tlrc.HEAD'[rwdtm#2_Coef]')
end
3dttest++ -prefix $dir_output/rwdtm#2_Coef.group.m1.nii -setA $list -mask $full_mask -toz

### DLPFC (High)
list=()
foreach nn ($list_high)
	subj="GP$nn"
	list=($list $dir_stat/$subj/statsRWDtime.$subj.SPMG2+tlrc.HEAD'[rwdtm#2_Coef]')
end
3dttest++ -prefix $dir_output/rwdtm#2_Coef.group.DLPFC_high.nii -setA $list -mask $full_mask -toz

## two-sample t-test 
setA=()
foreach nn ($list_m1)
	subj="GP$nn"
	setA=($setA $dir_stat/$subj/statsRWDtime.$subj.SPMG2+tlrc.HEAD'[rwdtm#2_Coef]')
end
setB=()
foreach nn ($list_DLPFC)
	subj="GP$nn"
	setB=($setB $dir_stat/$subj/statsRWDtime.$subj.SPMG2+tlrc.HEAD'[rwdtm#2_Coef]')
end
setC=()
foreach nn ($list_high)
	subj="GP$nn"
	setC=($setC $dir_stat/$subj/statsRWDtime.$subj.SPMG2+tlrc.HEAD'[rwdtm#2_Coef]')
end
3dttest++ -prefix ./M1-DLPFC_low.nii -setA $setA -setB $setB -mask $full_mask -toz
3dttest++ -prefix ./M1-DLPFC_high.nii -setA $setA -setB $setC -mask $full_mask -toz
