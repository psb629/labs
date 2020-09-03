#!/bin/tcsh

#######################################################################################
# variance parameters
#set subj = TML09_PILOT
set subj = TML29
set Reg_num = Reg8
set ROI_num = 58
set condition = updown_svc
#######################################################################################
# invariance parameters
set FreqType = (`echo $subj | cut -c3`)
set current_dir = `pwd`
set fMRI_dir = /clmnlab/TM/fMRI_data
set preproc_data_dir = $fMRI_dir/preproc_data/$subj
set behav_data_dir = /clmnlab/TM/behav_data/$subj
set anat_final = $preproc_data_dir/preprocessed/anat_final.$subj+tlrc.HEAD
set ROI_num = `echo | awk -v temp="$ROI_num" '{printf("%03s",temp);}'`
set AAL_ROI = /clmnlab/IN/AFNI_data/masks/AAL_ROI/AAL_ROI_{$ROI_num}.nii
set subj_full_mask = $preproc_data_dir/preprocessed/full_mask.$subj+tlrc.HEAD
set run = `echo | awk -v temp="$ROI_num" '{printf("r%02s",temp);}'`
set sungbeen_dir = $fMRI_dir/MVPA/sungbeen

########################################################################################
# check the validation
if (! -e $anat_final) then
	echo 'Can not find the' $anat_final
	exit
else
	set stat_subj_dir = $fMRI_dir/stats/{$Reg_num}_{*}/$subj
	if (! -d $stat_subj_dir) then
		echo 'Can not find the directory,' $stat_subj_dir
		exit
	endif
endif
set whole_brain = $stat_subj_dir/$run.stat.$subj+tlrc
set whole_brain_LSS = $stat_subj_dir/$run.LSSout+tlrc.HEAD
set subj_clust_mask = $stat_subj_dir/Clust_mask_binary.{$subj}.HEAD

#######################################################################################
# set the file of a freq order
set y1D = /clmnlab/TM/behav_data/$subj/$subj.Dis_freq_order.dat

########################################################################################
# voxel analysis
#3dinfo -verb $whole_brain
set pname = temp

#if (! -e $stat_subj_dir/$pname+tlrc.*) then
	#3dcalc -a $whole_brain'[1..479(2)]' -expr a -prefix $pname
#endif
#3dmaskave -quiet -mask $AAL_ROI $pname+tlrc.HEAD > $pname.txt

# multivoxel analysis
# vibration 1
#3dcalc -a $whole_brain_LSS'[0..$(5)]' -expr a -prefix $stat_subj_dir/$run.vib1.LSS
# vibration 2
# #3dcalc -a $whole_brain_LSS'[1..$(5)]' -expr a -prefix $stat_subj_dir/$run.vib2.LSS
#3dinfo -verb $stat_subj_dir/$run.vib1.LSS
#3dmaskave -quiet -mask $subj_full_mask $stat_subj_dir/$run.$pname.LSS+tlrc > $stat_subj_dir/$run.$pname.txt
#3dTcorr1D -prefix "$run.$pname.LSS.Tcorr1D" -spearman -mask $subj_full_mask -float "$stat_subj_dir/$run.$pname.LSS+tlrc.HEAD" $y1D_sed 
#rm $y1D_sed
#rm $stat_subj_dir/$run.$pname.LSS+tlrc.*

#aiv $run.X.jpg &
#1dplot $run.X.xmat.1D &
#1dplot $run.X.LSS.1D &

#1dmatcalc '&read($run.X.xmat.1D) &transp &read($run.X.LSS.1D) &mult &write($run.mult.1D)'
#1dplot $run.mult.1D &
#1dgrayplot $run.mult.1D &
########################################################################################
cd $stat_subj_dir
echo `pwd`
#afni $anat_final $stat_subj_dir $sungbeen_dir/{$subj}_r8_{$condition}+masked.nii.gz
afni $anat_final $stat_subj_dir/stat.{$subj}+tlrc
