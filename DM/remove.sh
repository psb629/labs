#!/bin/tcsh

set subj_list = DM01, DM02, DM03, DM04, DM05, DM06, DM07, DM08, DM09, DM10, \
		DM11, DM12, DM13, DM14, DM15, DM16, DM17, DM18, DM19, DM20, \
		DM21, DM22, DM23, DM24, DM25, DM26, DM27, DM28, DM29, DM30, \
		DM31
set root_dir = `pwd`

foreach subj ($subj_list)
	cd $root_dir/DMdata/subj/
	mv $subj_study.txt $root_dir
	mv $subj_test.txt $root_dir
	rm ./*
	mv $root_dir/$subj_study.txt ./
	mv $root_dir/$subj_test.txt ./
end
