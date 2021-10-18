#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================
root_dir=/Volumes/GoogleDrive/내\ 드라이브/GA
 #root_dir=/home/sungbeenpark/GoogleDrive/GA
behav_dir=$root_dir/behav_data
fmri_dir=$root_dir/fMRI_data
roi_dir=$fmri_dir/roi
stats_dir=$fmri_dir/stats
# ============================================================
work_dir=~/temp
if [ ! -d $work_dir ]; then
	mkdir -p -m 755 $work_dir
fi
# ============================================================
 #find $stats_dir/GLM.MO/tsmean -type f -size 0 -delete
find $work_dir -type f -size 0 -delete
# ============================================================
## Default mode network
DMN_dir=$roi_dir/DMN
DMNs=( Core_aMPFC_r Core_aMPFC_l Core_PCC_r Core_PCC_l \
	dMsub_dMPFC dMsub_LTC_l dMsub_LTC_r dMsub_TempP_l_temp dMsub_TempP_r_temp dMsub_TPJ_l dMsub_TPJ_r \
	MTLsub_HF_l MTLsub_HF_r MTLsub_PHC_l MTLsub_PHC_r MTLsub_pIPL_l MTLsub_pIPL_r MTLsub_Rsp_l MTLsub_Rsp_r MTLsub_vMPFC )
# ============================================================
## Yeo_network 1
fan_dir=$roi_dir/fan280
# No.105 FuG_L_3_2
# No.106 FuG_R_3_2
# No.189 MVOcC_L_5_1
# No.190 MVOcC_R_5_1
# No.193 MVOcC_L_5_3	
# No.194 MVOcC_R_5_3	
# No.196 MVOcC_R_5_4	
# No.199 LOcC_L_4_1
# No.200 LOcC_R_4_1
# No.203 LOcC_L_4_3	
# No.204 LOcC_R_4_3
# No.205 LOcC_L_4_4
# No.206 LOcC_R_4_4
# No.209 LOcC_L_2_2
fans=( 105 106 189 190 193 194 196 199 200 203 204 205 206 209 )
# ============================================================
## Localizer
localizer_dir=$roi_dir/localizer
localizers=( n200_c1_L_Postcentral\
			 n200_c2_R_CerebellumIV-V\
			 n200_c3_R_Postcentral\
			 n200_c4_L_Putamen\
			 n200_c5_R_SMA\
			 n200_c6_R_CerebellumVIIIb\
			 n200_c7_L_Thalamus )
# ============================================================
## regions
regions=()
foreach dmn ($DMNs)
	regions=($regions $dmn)
end
foreach fan ($fans)
	regions=($regions fan$fan)
end
foreach localizer ($localizers)
	regions=($regions $localizer)
end
## masks
masks=()
foreach dmn ($DMNs)
	masks=($masks $DMN_dir/$dmn.nii)
end
foreach fan ($fans)
	masks=($masks $fan_dir/fan.roi.GA.$fan.nii.gz)
end
foreach localizer ($localizers)
	masks=($masks $localizer_dir/${localizer}_mask.nii)
end
# ============================================================
## copy them to work_dir
foreach mask ($masks)
	cp -n $mask $work_dir
end
# ============================================================
## redirection paths of masks
masks=()
foreach dmn ($DMNs)
	masks=($masks $work_dir/$dmn.nii)
end
foreach fan ($fans)
	masks=($masks $work_dir/fan.roi.GA.$fan.nii.gz)
end
foreach localizer ($localizers)
	masks=($masks $work_dir/${localizer}_mask.nii)
end
# ============================================================
## check a validation by each mask
foreach mask ($masks)
	echo $mask
	3dBrickStat -count -non-zero $mask
end
# ============================================================
foreach nn ($nn_list)
	foreach gg (GA GB)
		subj=$gg$nn
		foreach run (r01 r02 r03 r04 r05 r06)
			data=$subj.bp_demean.errts.MO.$run.nii.gz
			aa=0
			foreach mask ($masks)
				aa=$[$aa+1]
				fname=tsmean.bp_demean.errts.MO.$subj.$run.$regions[$aa].1D
				## 만약 최종 output 이 없으면, 계산을 위한 데이터 복사부터 시작
				if [ ! -f $stats_dir/GLM.MO/tsmean/$regions[$aa]/$fname ]; then
					if [ ! -f $work_dir/$data ]; then
						echo "copying $data to $work_dir"
						cp -n $stats_dir/GLM.MO/$nn/$data $work_dir
					fi
					echo "Calculating ${gg}${nn} $run $regions[$aa] ..."
	 				output_dir=$work_dir/$regions[$aa]
 #					output_dir=$stats_dir/GLM.MO/tsmean/$regions[$aa]
					if [ ! -d $output_dir ]; then
						mkdir -p -m 755 $output_dir
					fi
					3dmaskave -quiet -mask $mask $work_dir/$data >$output_dir/$fname
 #					3dmaskave -quiet -mask $mask $stats_dir/GLM.MO/$nn/$data >$output_dir/$fname
				fi
			end
			if [ -f $work_dir/$data ]; then
				rm $work_dir/$data
			fi
		end
	end
end
foreach mask ($masks)
	rm $mask
end
cp -n -r $work_dir/* $stats_dir/GLM.MO/tsmean/
find $stats_dir/GLM.MO/tsmean -type f -size 0
