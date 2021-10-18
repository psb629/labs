#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
list_nn=( 01 )
# ============================================================
dname=GLM.RO
# ============================================================
dir_data=/mnt/sda2/GA/fmri_data/preproc_data
dir_gd=~/GoogleDrive
dir_roi=$dir_gd/GA/fMRI_data/roi
dir_stats=$dir_gd/GA/fMRI_data/stats
# ============================================================
# make a temporal directory to activate 3dDeconvolve
dir_tmp=~/GA/$dname
if [ ! -d $dir_tmp ]; then
	mkdir -p -m 755 $dir_tmp
fi
foreach nn ($list_nn)
 #	# define the dir_output in Google Drive
 #	dir_output=$dir_stats/$dname/$nn
 #	if [ ! -d $dir_output ]; then
 #		mkdir -p -m 755 $dir_output
 #	fi
	## re-define the dir_output in dir_tmp
	dir_output=$dir_tmp/$nn
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi
	foreach gg (GA GB)
		subj=$gg$nn
		## move main files to the dir_tmp directory
		mask=$dir_roi/full/full_mask.$subj.nii.gz
		foreach run (`seq -f "r%02g" 1 6`)
			## check the presence of the errts
			fin_res=$dir_output/$subj.bp_demean.errts.RO.$run.nii
			if [ -e $fin_res ]; then
				continue
			fi
		## move main files to the dir_tmp directory
			pb02=$dir_gd/GA/pb02/pb02.$subj.$run.volreg.nii.gz
 #			pb02=$dir_data/$subj/epi.volreg.$subj.$run.nii.gz
			censor=$dir_data/$subj/motion_censor.$subj.$run.1D
			cd $dir_output
			## AM = Amplitude Modulation
			## The -stim_times_AM* options have been modified to allow the input of multiple amplidues with each time.
			## -stim_times_AM1 still builds only 1 regressor, as before amplitude of each BLOCK (say) is modulated by sum of all extra amplitudes provided.
			3dDeconvolve -input $pb02 \
						-censor $censor \
						-mask $mask \
						-local_times -polort A -float \
						-num_stimts 7 \
						-num_glt 1 \
	 					-stim_times_AM2 1 $dir_gd/GA/behav_data/regressors/rewards/$subj.${run}rew1000.GAM.1D 'SPMG2' \
						-stim_label 1 RO \
						-stim_file 2 "$dir_data/$subj/motion_demean.$subj.$run.1D[0]" -stim_base 2 -stim_label 2 roll \
						-stim_file 3 "$dir_data/$subj/motion_demean.$subj.$run.1D[1]" -stim_base 3 -stim_label 3 pitch \
						-stim_file 4 "$dir_data/$subj/motion_demean.$subj.$run.1D[2]" -stim_base 4 -stim_label 4 yaw \
						-stim_file 5 "$dir_data/$subj/motion_demean.$subj.$run.1D[3]" -stim_base 5 -stim_label 5 dS \
						-stim_file 6 "$dir_data/$subj/motion_demean.$subj.$run.1D[4]" -stim_base 6 -stim_label 6 dL \
						-stim_file 7 "$dir_data/$subj/motion_demean.$subj.$run.1D[5]" -stim_base 7 -stim_label 7 dP \
						-x1D $dir_output/$subj.X.RO.$run.1D \
						-xjpeg $dir_output/$subj.X.RO.$run.jpg \
						-x1D_uncensored $dir_output/$subj.X.nocensor.RO.$run.1D \
						-errts $dir_output/$subj.errts.RO.$run.nii \
						-bucket $dir_output/$subj.stats.RO.$run.nii

			3dTproject -polort 0 -input $dir_output/$subj.errts.RO.$run.nii \
					-mask $mask \
					-passband 0.01 0.1 \
					-cenmode ZERO \
					-prefix $fin_res
		end
	end
end
 #	# ============================================================
 #	3dAFNItoNIFTI -prefix $dir_output/statMove.$nn.nii.gz $dir_output/statMove.$nn+tlrc.
 #	# ============================================================
 # #	gzip -1v $dir_output/*.BRIK
 #	rm $dir_output/statMove.$nn+tlrc.*
 #	# ============================================================
 #	echo "subject GA$nn completed"
 #end
# ============================================================
## group t-test
 #set dir_output = $dir_stats/$dname
 #set group_dir = $dir_output/group
 #if ( ! -d $group_dir ) then
 #	mkdir -p -m 755 $group_dir
 #endif
 #
 #set temp = ()
 #foreach nn ($subj_list)
 #	3dcalc -a $dir_output/$nn/"statMove.$nn.nii.gz[7]" -expr "a" -prefix $group_dir/temp.$nn.nii.gz
 #	set temp = ($temp $group_dir/temp.$nn.nii.gz)
 #end
 #
 #set gmask = $dir_roi/full_mask.GAs.nii.gz
 #set pname = $dir_output/group.statMove.nii.gz
 #3dttest++ -mask $gmask -setA $temp -prefix $pname
 #rm -r $group_dir
# ============================================================
