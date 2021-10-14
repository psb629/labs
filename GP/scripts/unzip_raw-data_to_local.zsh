#!/bin/zsh

list_subj=(08 09 10 11 17 18 20 21)
list_subj=(09 10 11 17 18 20 21)

foreach nn in $list_subj
	subj=GP$nn
	
	dir_input=~/GoogleDrive/GP/fmri_data
	input=$dir_input/$subj.zip

	dir_output=~/GP
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi

	## compress
	unzip $input -d $dir_output -x "*.DS_Store" "*dimon.files.run.*" "*GERT_Reco_dicom_*" "*__MACOSX"
end
