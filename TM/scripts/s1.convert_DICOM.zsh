#!/bin/zsh

##############################################################
## $# = the number of arguments
while (( $# )); do
	key="$1"
	case $key in
##		pattern)
##			sentence
##		;;
		-s | --subject)
			subj="$2"
		;;
	esac
	shift ##takes one argument
done
##############################################################
dir_root="/mnt/ext4/TM/fmri_data"
dir_raw="$dir_root/raw_data/$subj"

dir_output=$dir_raw
if [ ! -d $dir_output ]; then
	mkdir -p -m 755 $dir_output
fi
##############################################################
## T1
dname=`find $dir_raw -type d -name "T1_MPRAGE_SAG_1_0ISO_00??"`
dcm2niix_afni						\
	-a y -o $dir_output -f T1.$subj	\
	$dname

## EPI
for rr in {1..5..1}
{
	dname=`find $dir_raw -type d -name "RUN${rr}_MB3_2ISO__00??"`
	run=`printf "r%02d" $rr`
	dcm2niix_afni								\
		-a y -o $dir_output -f func.$run.$subj	\
		$dname
}
