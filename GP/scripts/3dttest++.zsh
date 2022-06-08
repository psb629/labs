#!/bin/zsh

list_DLPFC=('09' '10' '18' '21' '22' '24' '27' '34' '35' '36' '38')
list_sham=('08' '11' '17' '19' '20' '26' '32' '33' '37' '39' '40' '41')
# ============================================================
dir_root="/mnt/ext6/GP/fmri_data"
dir_stat="$dir_root/stats/AM/reward"
dir_mask="$dir_root/masks/"
# ============================================================
dir_output=$dir_stat
# ============================================================
list=(`ls $dir_stat/GP??/statsRWDtime.GP??.SPMG2+tlrc.HEAD`)
foreach fname ($list)
	subj=$fname[-20,-17]
	3dcalc -a $fname'[rwdtm#2_Coef]' -expr 'a' -prefix $dir_stat/$subj/rwdtm-2_Coef.$subj.nii
end

cd $dir_output
list=()
foreach nn ($list_sham)
	subj="GP$nn"
	list=($list $dir_stat/$subj/rwdtm-2_Coef.$subj.nii)
end
3dttest++ -prefix rwdtm-2_Coef.group.Sham.nii -setA $list -mask $dir_mask/full_mask.GP.group.nii -toz

cd $dir_output
list=()
foreach nn ($list_DLPFC)
	subj="GP$nn"
	list=($list $dir_stat/$subj/rwdtm-2_Coef.$subj.nii)
end
3dttest++ -prefix rwdtm-2_Coef.group.DLPFC.nii -setA $list -mask $dir_mask/full_mask.GP.group.nii -toz

cd $dir_output
setA=()
foreach nn ($list_sham)
	subj="GP$nn"
	setA=($setA $dir_stat/$subj/rwdtm-2_Coef.$subj.nii)
end
setB=()
foreach nn ($list_DLPFC)
	subj="GP$nn"
	setB=($setB $dir_stat/$subj/rwdtm-2_Coef.$subj.nii)
end
3dttest++ -prefix ./Sham-DLPFC.nii -setA $setA -setB $setB -mask $dir_mask/full_mask.GP.group.nii -toz
