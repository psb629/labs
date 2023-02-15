#!/bin/zsh

## ============================================================ ##
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-s | --subject)
			## string
			subj="$2"
		;;
	esac
	shift ##takes one argument
done
## ============================================================ ##
dir_root="/mnt/ext4/GL/fmri_data"
dir_raw="$dir_root/raw_data"
dir_preproc="$dir_root/preproc_data"
## ============================================================ ##
dir_output="$dir_raw/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi

dir_t1=`find "$dir_raw/$subj" -maxdepth 1 -mindepth 1 -type d -name "MPRAGE"`
	
cd $dir_t1
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/MPRAGE.$subj.nii $dir_output/temp+orig
rm $dir_output/temp*

for nn in `seq -f '%02g' 1 7`
{
	dir_run=`find "$dir_raw/$subj" -maxdepth 1 -mindepth 1 -type d -name "r$nn"`

	cd $dir_run
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.r$nn.nii $dir_output/temp+orig
	rm $dir_output/temp*
}	
