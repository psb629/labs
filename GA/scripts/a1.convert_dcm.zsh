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
dir_root="/mnt/ext5/GA/fmri_data"
dir_raw="$dir_root/raw_data"
dir_preproc="$dir_root/preproc_data"
## ============================================================ ##
dir_output="$dir_raw/$subj"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
## ============================================================ ##
## T1
T1=`find "$dir_raw/$subj" -maxdepth 1 -mindepth 1 -type d -name "*MPRAGE*"`

cd $T1
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/MPRAGE.$subj.nii $dir_output/temp+orig
rm $dir_output/temp*
## ============================================================ ##
## Distortion correction
dist_PA=`find "$dir_raw/$subj" -maxdepth 1 -mindepth 1 -type d -name "dist_PA"`
dist_AP=`find "$dir_raw/$subj" -maxdepth 1 -mindepth 1 -type d -name "dist_AP"`

cd $dist_PA
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/dist_PA.$subj.nii $dir_output/temp+orig
rm $dir_output/temp*

cd $dist_AP
Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
-gert_outdir $dir_output -gert_quit_on_err
3dWarp -deoblique -prefix $dir_output/dist_AP.$subj.nii $dir_output/temp+orig
rm $dir_output/temp*
## ============================================================ ##
## EPI
if [ $subj[2] = 'A' ]; then
{
	list_run=(`seq -f '%02g' 0 7`)
}
elif [ $subj[2] = 'B' ]; then
{
	list_run=(`seq -f '%02g' 1 7`)
}
fi

for rr in $list_run
{
	run="r$rr"
	dir=`find "$dir_raw/$subj" -maxdepth 1 -mindepth 1 -type d -name "$run"`
	dir_SBREF=`find "$dir_raw/$subj" -maxdepth 1 -mindepth 1 -type d -name "${run}_SBREF"`
	
	cd $dir
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.$run.nii $dir_output/temp+orig
	rm $dir_output/temp*
	
	cd $dir_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.$run.nii $dir_output/temp+orig
	rm $dir_output/temp*
}
