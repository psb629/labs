#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )

root_dir=~/Desktop/root_dir
search_dir=$root_dir/searchlight

foreach nn ($nn_list)
	cp $search_dir/1to3/GA${nn}_r6_lda_pos.nii.gz $search_dir/$nn.lda.r6.early_practice.nii.gz
	cp $search_dir/1to3/GB${nn}_r6_lda_pos.nii.gz $search_dir/$nn.lda.r6.late_practice.nii.gz
	cp $search_dir/4to6/GA${nn}_r6_lda_pos.nii.gz $search_dir/$nn.lda.r6.early_unpractice.nii.gz
	cp $search_dir/4to6/GB${nn}_r6_lda_pos.nii.gz $search_dir/$nn.lda.r6.late_unpractice.nii.gz
end
