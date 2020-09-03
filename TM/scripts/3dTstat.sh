#!/bin/tcsh

set subj_list = (\
				TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML10_PILOT TML11_PILOT \
				TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20 \
				TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29 \
				)
set TM_dir = /clmnlab/TM
set fMRI_dir = $TM_dir/fMRI_data
set root_dir = $fMRI_dir/MVPA/sungbeen
set stat_dir_8 = $fMRI_dir/stats/Reg8_{*}
set anat_TML29 = $fMRI_dir/preproc_data/TML29/preprocessed
set setA_temp = ()

set run_num = 2
switch ($run_num)
	case 1:
		set prfx = $root_dir/TTNew
		foreach subj ($subj_list)
			set setA_temp = ($setA_temp $root_dir/{$subj}_r8_updown_svc+masked.nii.gz)
		end
		3dttest++ -setA $setA_temp -prefix $prfx
		afni {$prfx}+tlrc $anat_TML29
		breaksw
	case 2:
		breaksw
	default:
		breaksw
endsw
