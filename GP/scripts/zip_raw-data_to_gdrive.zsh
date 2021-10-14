#!/bin/zsh

list_subj=(08 09 10 11 17 18 20 21)

foreach nn in $list_subj
	subj=GP$nn
	
	dir_input=~/Desktop/GP

	dir_output="/Users/clmn/Google Drive/내 드라이브/GP/fmri_data"
	if [ ! -d $dir_output ]; then
		mkdir -p -m 755 $dir_output
	fi
	output=$dir_output/$subj.zip

	## compress
	cd $dir_input
	input=$subj
	zip -r $output $input -x "*.DS_Store" "*dimon.files.run.*" "*GERT_Reco_dicom_*" "*__MACOSX"
end
