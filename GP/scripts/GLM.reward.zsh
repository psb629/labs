#!/bin/zsh

## No data : GP16
list_nn=('08' '09' '10' '11' '17'\
	'18' '19' '20' '21' '22'\
	'24' '26' '27' '32' '33'\
	'34' '35' '36' '37' '38'\
	'39' '40' '41')
# ============================================================
dir_preproc="/mnt/sdb2/GP/fmri_data/preproc_data"
dir_root="/mnt/ext6/GP"
dir_reg="$dir_root/behav_data/regressors/AM"
# ============================================================
foreach nn ($list_nn)
	subj="GP$nn"

	dir_output="$dir_root/fmri_data/stats/AM/reward/$subj"
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi

	## convert motion_demean (1096,6) to mot_demean (1096*3,6)
	~/Github/labs/GP/scripts/convert.mot_demean.rxx.py $subj

	cd $dir_output
	## 'SPMG2' : generate 4 regeressors ( mean f(x), mean f'(x), delta f(x), delta f'(x) )
	3dDeconvolve \
		-input $dir_preproc/$subj/day2/preprocessed/pb04.$subj.r??.scale+tlrc.HEAD \
		-censor $dir_preproc/$subj/day2/preprocessed/motion_${subj}_censor.1D \
		-mask $dir_preproc/$subj/day2/preprocessed/full_mask.$subj+tlrc.HEAD \
    	-ortvec $dir_preproc/$subj/day2/preprocessed/mot_demean.$subj.r01.1D 'mot_demean_r01' \
	    -ortvec $dir_preproc/$subj/day2/preprocessed/mot_demean.$subj.r02.1D 'mot_demean_r02' \
	    -ortvec $dir_preproc/$subj/day2/preprocessed/mot_demean.$subj.r03.1D 'mot_demean_r03' \
		-polort A -float \
		-allzero_OK \
		-num_stimts 1 \
		-stim_times_AM2 1 $dir_reg/$subj.AM.onset-reward.1D 'SPMG2' -stim_label 1 'rwdtm' \
		-num_glt 1 \
		-gltsym 'SYM: rwdtm' -glt_label 1 'rwdtm' \
		-jobs 8 -fout -tout \
		-x1D X.xmat.$subj.SPMG2.1D -xjpeg X.$subj.SPMG2.jpg \
		-bucket statsRWDtime.$subj.SPMG2
 #		-errts errts.$subj.SPMG2
 #		-mask $dir_root/fmri_data/masks/mask.Caudate.GA.nii \
	echo "subject $subj completed"
end
