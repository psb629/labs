#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
nn_list=( 01 )
# ============================================================
dir_root=/home/sungbeenpark/GA
dir_stats=$dir_root/GLM.RO

dir_gd=/home/sungbeenpark/GoogleDrive
dir_roi=$dir_gd/GA/fMRI_data/roi
# ============================================================
dir_work=$dir_root/tmp
if [ ! -d $dir_work ]; then
	mkdir -p -m 755 $dir_work
fi
# ============================================================
 #find $dir_stats/GLM.MO/tsmean -type f -size 0 -delete
 #find $dir_work -type f -size 0 -delete
# ============================================================
## Default mode network
dir_DMN=$dir_roi/DMN
DMNs=( Core_aMPFC_r Core_aMPFC_l Core_PCC_r Core_PCC_l \
	dMsub_dMPFC dMsub_LTC_l dMsub_LTC_r dMsub_TempP_l_temp dMsub_TempP_r_temp dMsub_TPJ_l dMsub_TPJ_r \
	MTLsub_HF_l MTLsub_HF_r MTLsub_PHC_l MTLsub_PHC_r MTLsub_pIPL_l MTLsub_pIPL_r MTLsub_Rsp_l MTLsub_Rsp_r MTLsub_vMPFC )
# ============================================================
## Yeo_network 1
dir_fan=$dir_roi/fan280
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
dir_localizer=$dir_roi/localizer
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
	masks=($masks $dir_DMN/$dmn.nii)
end
foreach fan ($fans)
	masks=($masks $dir_fan/fan.roi.GA.$fan.nii.gz)
end
foreach localizer ($localizers)
	masks=($masks $dir_localizer/${localizer}_mask.nii)
end
# ============================================================
 ### copy them to dir_work
 #foreach mask ($masks)
 #	cp -n $mask $dir_work
 #end
 ## ============================================================
 ### redirection paths of masks
 #masks=()
 #foreach dmn ($DMNs)
 #	masks=($masks $dir_work/$dmn.nii)
 #end
 #foreach fan ($fans)
 #	masks=($masks $dir_work/fan.roi.GA.$fan.nii.gz)
 #end
 #foreach localizer ($localizers)
 #	masks=($masks $dir_work/${localizer}_mask.nii)
 #end
 ## ============================================================
 ### check a validation by each mask
 #foreach mask ($masks)
 #	echo $mask
 #	3dBrickStat -count -non-zero $mask
 #end
# ============================================================
foreach nn ($nn_list)
	foreach gg (GA GB)
		subj=$gg$nn
		foreach run (r01 r02 r03 r04 r05 r06)
			data=$subj.bp_demean.errts.RO.$run.nii
			aa=0
			foreach mask ($masks)
				aa=$[$aa+1]
				dir_output=/home/sungbeenpark/GA/GLM.RO/tsmean/$regions[$aa]
				if [ ! -d $dir_output ]; then
					mkdir -p -m 755 $dir_output
				fi
				fname=tsmean.bp_demean.errts.RO.$subj.$run.$regions[$aa].1D
				## 최종 output이 이미 존재하는가?
				if [ ! -e $dir_output/$fname ]; then
					## 계산을 위한 데이터 복사부터 시작
					if [ ! -e $dir_work/$data ]; then
						echo "copying $data to $dir_work"
						cp -n $dir_stats/$nn/$data $dir_work
					fi
					## 
					echo "Calculating ${gg}${nn} $run $regions[$aa] ..."
					3dmaskave -quiet -mask $mask $dir_work/$data >$dir_output/$fname
				fi
			end
			## 해당 subj에 대한 계산이 완료되었으므로 임시로 복사한 데이터는 삭제
			if [ -f $dir_work/$data ]; then
				rm $dir_work/$data
			fi
		end
	end
end
find $dir_output -type f -size 0
