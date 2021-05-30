#!/bin/zsh


subj=GAB07
T1_dir=/Users/clmn/Desktop/${subj}_T1

output_dir=/Users/clmn/Desktop/T1
if [ ! -d $output_dir ]; then
	mkdir -p -m 755 $output_dir
fi

cd $T1_dir
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
		  -gert_outdir $output_dir -gert_quit_on_err
3dWarp -deoblique -prefix $output_dir/anat.$subj.nii.gz $output_dir/temp+orig
rm $output_dir/temp*
