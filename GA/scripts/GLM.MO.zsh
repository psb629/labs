#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================
dname=GLM.MO
# ============================================================
data_dir=/Volumes/GoogleDrive/내\ 드라이브/GA/pb02
root_dir=/Volumes/GoogleDrive/내\ 드라이브/GA
behav_dir=$root_dir/behav_data
fmri_dir=$root_dir/fMRI_data
roi_dir=$fmri_dir/roi
stats_dir=$fmri_dir/stats
# ============================================================
# make a temporal directory to activate 3dDeconvolve
temp_dir=~/Desktop/temp
if [ ! -d $temp_dir ]; then
	mkdir -p -m 755 $temp_dir
fi
foreach nn ($nn_list)
	# define the output_dir in Google Drive
	output_dir=$stats_dir/$dname/$nn
	if [ ! -d $output_dir ]; then
		mkdir -p -m 755 $output_dir
	fi
	## re-define the output_dir in temp_dir
	output_dir=$temp_dir/$nn
	if [ ! -d $output_dir ]; then
		mkdir -p -m 755 $output_dir
	fi
	foreach gg (GA GB)
		subj=$gg$nn
		## move main files to the temp_dir directory
		mask=full_mask.$subj.nii.gz
		cp -n $roi_dir/full/$mask \
			$temp_dir/$mask
		foreach rr (`seq -f "%02g" 1 6`)
			## check the presence of the errts
			fin_res=$output_dir/$subj.bp_demean.errts.MO.r$rr.nii.gz
			if [ -f $fin_res ]; then
				continue
			fi
			## move main files to the temp_dir directory
			pb02=pb02.$subj.r$rr.volreg.nii.gz
			cp -n $data_dir/$pb02 \
				$temp_dir/$pb02
			censor=motion_censor.$subj.r$rr.1D
			cp -n $fmri_dir/preproc_data/$nn/$censor \
				$temp_dir/$consor
			cd $output_dir
			## AM = Amplitude Modulation
			## The -stim_times_AM* options have been modified to allow the input of multiple amplidues with each time.
			## -stim_times_AM1 still builds only 1 regressor, as before amplitude of each BLOCK (say) is modulated by sum of all extra amplitudes provided.
			3dDeconvolve -input $temp_dir/$pb02 \
						-censor $temp_dir/$censor \
						-mask $temp_dir/$mask \
						-local_times -polort A -float \
						-num_stimts 7 \
						-num_glt 1 \
						-stim_times_AM1 1 $behav_dir/regressors/4targets/$subj.AMregressor.4targets.r$rr.1D 'BLOCK(5,1)' \
						-stim_label 1 MO \
						-stim_file 2 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[0]" -stim_base 2 -stim_label 2 roll \
						-stim_file 3 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[1]" -stim_base 3 -stim_label 3 pitch \
						-stim_file 4 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[2]" -stim_base 4 -stim_label 4 yaw \
						-stim_file 5 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[3]" -stim_base 5 -stim_label 5 dS \
						-stim_file 6 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[4]" -stim_base 6 -stim_label 6 dL \
						-stim_file 7 "$fmri_dir/preproc_data/$nn/motion_demean.$subj.r$rr.1D[5]" -stim_base 7 -stim_label 7 dP \
						-x1D $output_dir/$subj.X.MO.r$rr.1D \
						-xjpeg $output_dir/$subj.X.MO.r$rr.jpg \
						-x1D_uncensored $output_dir/$subj.X.nocensor.MO.r$rr.1D \
						-errts $output_dir/$subj.errts.MO.r$rr.nii.gz \
						-bucket $output_dir/$subj.stats.MO.r$rr.nii.gz

			3dTproject -polort 0 -input $output_dir/$subj.errts.MO.r$rr.nii.gz \
					-mask $temp_dir/$mask \
					-passband 0.01 0.1 \
					-cenmode ZERO \
					-prefix $fin_res
			## move the temporal directory to Google Drive
			cp -n $output_dir/* $stats_dir/$dname/$nn/
			## remove useless files
			rm $temp_dir/$pb02 \
				$temp_dir/$censor
			rm $output_dir/*
		end
		rm $temp_dir/$mask
	end
end
rm -r $temp_dir
 #	# ============================================================
 #	3dAFNItoNIFTI -prefix $output_dir/statMove.$nn.nii.gz $output_dir/statMove.$nn+tlrc.
 #	# ============================================================
 # #	gzip -1v $output_dir/*.BRIK
 #	rm $output_dir/statMove.$nn+tlrc.*
 #	# ============================================================
 #	echo "subject GA$nn completed"
 #end
# ============================================================
## group t-test
 #set output_dir = $stats_dir/$dname
 #set group_dir = $output_dir/group
 #if ( ! -d $group_dir ) then
 #	mkdir -p -m 755 $group_dir
 #endif
 #
 #set temp = ()
 #foreach nn ($subj_list)
 #	3dcalc -a $output_dir/$nn/"statMove.$nn.nii.gz[7]" -expr "a" -prefix $group_dir/temp.$nn.nii.gz
 #	set temp = ($temp $group_dir/temp.$nn.nii.gz)
 #end
 #
 #set gmask = $roi_dir/full_mask.GAs.nii.gz
 #set pname = $output_dir/group.statMove.nii.gz
 #3dttest++ -mask $gmask -setA $temp -prefix $pname
 #rm -r $group_dir
# ============================================================
