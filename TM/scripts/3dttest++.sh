#!/bin/tcsh

set subj_list = (\
				TML04_PILOT TML05_PILOT TML06_PILOT TML07_PILOT TML08_PILOT TML09_PILOT TML10_PILOT TML11_PILOT \
				TML12_PILOT TML13 TML14 TML15 TML16 TML18 TML19 TML20 \
				TML21 TML22 TML23 TML24 TML25 TML26 TML28 TML29 \
				)
set TM_dir = /clmnlab/TM
set fMRI_dir = $TM_dir/fMRI_data
set root_dir = $fMRI_dir/MVPA/sungbeen
set stat_dir_8 = $fMRI_dir/stats/Reg8_{*}
set stat_dir_10 = $fMRI_dir/stats/Reg10_{*}
set stat_dir_11 = $fMRI_dir/stats/Reg11_{*}
set stat_dir_12 = $fMRI_dir/stats/Reg12_{*}
set anat_TML29 = $fMRI_dir/preproc_data/TML29/preprocessed
set setA_temp = ()

set run_num = 5
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
	cd $TM_dir
	set prfx = $root_dir/TT4mask
	rm {$prfx}+tlrc.*
	foreach subj ($subj_list)
		set subj_dataset = $stat_dir_8/$subj/stat.{$subj}+tlrc.HEAD
		3dcalc -a $subj_dataset'[1]' -expr a -prefix $TM_dir/temp_{$subj}
	end
	3dttest++ -setA $TM_dir/temp_*+tlrc.HEAD
	#3dttest++ -setA $TM_dir/temp_*+tlrc.HEAD -Clustsim -prefix $prfx
	#3dttest++ -setA $TM_dir/temp_*+tlrc.HEAD -ETAC_global -prefix_clustsim freq15
	rm $TM_dir/temp_*+tlrc.*
	breaksw
case 3:
	foreach subj ($subj_list)
		cd $stat_dir_10/$subj
		set LSS1 = ./r01.LSSout.nii.gz
		set LSS2 = ./r02.LSSout.nii.gz
		set LSS3 = ./r03.LSSout.nii.gz
		## beta_freq.1
		3dTcat $LSS1'[0..$(4)]' $LSS2'[0..$(4)]' $LSS3'[0..$(4)]' -prefix LSS123.tcat
		3dttest++ -setA ./LSS123.tcat+tlrc.HEAD -prefix LSS123.ttest
		rm ./LSS123.tcat+tlrc.*
		3dClusterize -nosum -1Dformat -inset ./LSS123.ttest+tlrc.HEAD -idat 1 -ithr 1 -NN 2 -clust_nvox 40 -bisided p=0.001 -pref_map temp
		rm ./LSS123.ttest+tlrc.*
 		3dcalc -a temp+tlrc -expr 'ispositive(a)' -prefix Clust_mask_binary
 		3dAFNItoNIFTI -prefix Clust_mask_binary.nii.gz ./Clust_mask_binary+tlrc
		rm ./temp+tlrc.* ./Clust_mask_binary+tlrc.*
	end
	breaksw
case 4:
	set fname = Clust_mask_binary.nii.gz
	foreach subj ($subj_list)
		cd $stat_dir_11/$subj
		set LSS1 = ./r01.LSSout.nii.gz
		set LSS2 = ./r02.LSSout.nii.gz
		set LSS3 = ./r03.LSSout.nii.gz
		## beta_freq.1
		3dTcat $LSS1'[0..$(4)]' $LSS2'[0..$(4)]' $LSS3'[0..$(4)]' -prefix LSS123.tcat
		3dttest++ -setA ./LSS123.tcat+tlrc.HEAD -prefix LSS123.ttest
		rm ./LSS123.tcat+tlrc.*
		3dClusterize -nosum -1Dformat -inset ./LSS123.ttest+tlrc.HEAD -idat 1 -ithr 1 -NN 2 -clust_nvox 40 -bisided p=0.001 -pref_map temp
		rm ./LSS123.ttest+tlrc.*
 		3dcalc -a temp+tlrc -expr 'ispositive(a)' -prefix Clust_mask_binary
 		3dAFNItoNIFTI -prefix $fname ./Clust_mask_binary+tlrc
		rm ./temp+tlrc.* ./Clust_mask_binary+tlrc.*
	end
	breaksw
case 5:
	set fname = Clust_mask_binary.nii.gz
	foreach subj ($subj_list)
		cd $stat_dir_12/$subj
		set LSS1 = ./r01.LSSout.nii.gz
		set LSS2 = ./r02.LSSout.nii.gz
		set LSS3 = ./r03.LSSout.nii.gz
		## beta_freq.1
		3dTcat $LSS1'[0..$(6)]' $LSS2'[0..$(6)]' $LSS3'[0..$(6)]' -prefix LSS123.tcat
		3dttest++ -setA ./LSS123.tcat+tlrc.HEAD -prefix LSS123.ttest
		rm ./LSS123.tcat+tlrc.*
		3dClusterize -nosum -1Dformat -inset ./LSS123.ttest+tlrc.HEAD -idat 1 -ithr 1 -NN 2 -clust_nvox 40 -bisided p=0.001 -pref_map temp
		rm ./LSS123.ttest+tlrc.*
 		3dcalc -a temp+tlrc -expr 'ispositive(a)' -prefix Clust_mask_binary
 		3dAFNItoNIFTI -prefix $fname ./Clust_mask_binary+tlrc
		rm ./temp+tlrc.* ./Clust_mask_binary+tlrc.*
	end
	breaksw
default:
	breaksw
endsw
