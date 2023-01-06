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
		-d | --day)
			## integer('1' or '2')
			dd="$2"
		;;
	esac
	shift ##takes one argument
done
day="day$dd"
## ============================================================ ##
dir_root="/mnt/ext5/GP/fmri_data"
dir_raw="$dir_root/raw_data"
dir_preproc="$dir_root/preproc_data"
## ============================================================ ##
dir_output="$dir_raw/$subj/$day"
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi

if [ $day = 'day1' ]; then
	T1=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "T1*"`
	dist_PA=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_INVERT_TO_PA_00??"`
	dist_AP=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_AP_00??"`
	r00=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "TASK_MUITIBAND8_EPI_CMRR_00??"`
	r00_SBREF=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "TASK_MUITIBAND8_EPI_CMRR_SBREF_00??"`
	
	cd $T1
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/MPRAGE.$subj.nii $dir_output/temp+orig
	rm $dir_output/temp*
	
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
	
	cd $r00
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.localizer.nii $dir_output/temp+orig
	rm $dir_output/temp*
	
	cd $r00_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.localizer.nii $dir_output/temp+orig
	rm $dir_output/temp*

elif [ $day = 'day2' ]; then
	dist_PA=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_INVERT_TO_PA_00??"`
	dist_AP=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "DISTORTION_CORR_64CH_AP_00??"`
	r01=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "RUN1_MUITIBAND8_EPI_CMRR_00??"`
	r01_SBREF=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "RUN1_MUITIBAND8_EPI_CMRR_SBREF_00??"`
	r02=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "RUN2_MUITIBAND8_EPI_CMRR_00??"`
	r02_SBREF=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "RUN2_MUITIBAND8_EPI_CMRR_SBREF_00??"`
	r03=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "RUN3_MUITIBAND8_EPI_CMRR_00??"`
	r03_SBREF=`find "$dir_raw/$subj/$day" -maxdepth 1 -mindepth 1 -type d -name "RUN3_MUITIBAND8_EPI_CMRR_SBREF_00??"`

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
	
	cd $r01
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.r01.nii $dir_output/temp+orig
	rm $dir_output/temp*
	
	cd $r01_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.r01.nii $dir_output/temp+orig
	rm $dir_output/temp*

	cd $r02
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.r02.nii $dir_output/temp+orig
	rm $dir_output/temp*
	
	cd $r02_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.r02.nii $dir_output/temp+orig
	rm $dir_output/temp*

	cd $r03
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/func.$subj.r03.nii $dir_output/temp+orig
	rm $dir_output/temp*
	
	cd $r03_SBREF
	Dimon -infile_pat '*.IMA' -gert_create_dataset -gert_to3d_prefix temp \
	-gert_outdir $dir_output -gert_quit_on_err
	3dWarp -deoblique -prefix $dir_output/SBREF.$subj.r03.nii $dir_output/temp+orig
	rm $dir_output/temp*
fi
