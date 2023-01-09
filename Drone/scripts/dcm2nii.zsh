#!/bin/zsh

###################################################3
subj="DRN02"
###################################################3
dir_root="/mnt/ext1/Drone/fmri_data/raw_data"

for rr in 1 2 3 4
{
	dir_task=`find $dir_root/$subj -type d -name "RUN${rr}*"`

	cd $dir_task
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
}

 #cd $dir_root/$subj
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $output_dir -gert_quit_on_err
	3dWarp -deoblique -prefix $output_dir/dist.PA.$subj $output_dir/temp+orig
	rm $output_dir/temp*
