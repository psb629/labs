ii_list=( GA GB )
nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )

root_dir=/Volumes/T7SSD1/GA
fmri_dir=$root_dir/fMRI_data
search_dir=$fmri_dir/searchlight

output_dir=$search_dir
#=====================================================
## make the group full-mask
foreach ii ($ii_list)
	gmask=$fmri_dir/roi/full_mask.${ii}s.nii.gz
	temp=()
	foreach nn ($nn_list)
		subj=$ii$nn
		temp=($temp $fmri_dir/roi/full/full_mask.$subj.nii.gz)
	end
	pname=$fmri_dir/roi/full_mask.${ii}s.nii.gz
	if [ ! -e $pname ]; then
		3dMean -mask_inter -prefix $pname $temp
	fi
end
pname=$fmri_dir/roi/full_mask.GAGB.nii.gz
if [ ! -e $pname ]; then
	3dMean -mask_inter -prefix $pname $fmri_dir/roi/full_mask.GAs.nii.gz $fmri_dir/roi/full_mask.GBs.nii.gz
fi
#=====================================================
## group t-test for a visit separately
foreach ii ($ii_list)
	gmask=$fmri_dir/roi/full_mask.${ii}s.nii.gz
	temp=()
	foreach nn ($nn_list)
		subj=$ii$nn
		temp=($temp $search_dir/1to3/${subj}_r6_lda_pos.nii.gz)
	end
	pname=$output_dir/group.${ii}s.1to3.nii.gz
	if [ ! -e $pname ]; then
		3dttest++ -prefix $pname -mask $gmask -setA $temp
	fi
end
#=====================================================
## paired t-test: setA-setB
## make buckets
foreach ii ($ii_list)
	temp=()
	foreach nn ($nn_list)
		subj=$ii$nn
		temp=($temp $search_dir/1to3/${subj}_r6_lda_pos.nii.gz)
	end
	buck=$output_dir/temp.$ii.buck.nii.gz
	if [ ! -e $buck ]; then
		3dbucket -prefix $buck $temp
	fi
end
## Warning! Cannot use -Clustsim when -prefix has an absolute path
gmask=$fmri_dir/roi/full_mask.GAGB.nii.gz
pname=group.GB-GA.1to3.nii.gz
cd $output_dir
if [ ! -e $pname ]; then
3dttest++ -prefix $pname -setA $output_dir/temp.GB.buck.nii.gz -setB $output_dir/temp.GA.buck.nii.gz \
		-paired -clustsim -mask $gmask
fi
rm $output_dir/temp.G?.buck.nii.gz
