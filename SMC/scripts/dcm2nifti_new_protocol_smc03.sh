#!/bin/tcsh

set root_dir = /Users/clmn/Desktop/Samsung_Hospital
set dcm_dir = $root_dir/SMC-2020-03_200812_fmri
set output_dir = $root_dir/SMC03

set TR = 2

set cnt = 0
set set_time = `count -digit 1 1 300`
foreach t_ini ($set_time)
	set set_data = `count -digit 4 $t_ini 18001 300`
	foreach n ($set_data)
		@ cnt = $cnt + 1
		set n_prime = `printf %05d $cnt`
		cp $dcm_dir/SMC-2020-03.dcm$n.dcm $output_dir/temp$n_prime.dcm
	end
	set t = `printf %03d $t_ini`
	dcm2niix_afni -o $output_dir -s y -z y -f "SMC03_func$t" $output_dir
	rm $output_dir/*.dcm
	rm $output_dir/*.json
end
3dTcat -tr $TR -prefix $output_dir/pb00.SMC03.tcat $output_dir/*.nii.gz
3dAFNItoNIFTI -prefix $output_dir/SMC03_fMRI.nii.gz $output_dir/pb00.SMC03.tcat+orig.
