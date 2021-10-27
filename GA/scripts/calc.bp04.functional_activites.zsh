#!/bin/zsh
#
list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 )
 #		  36 37 38 42 44 )
list_run=(`seq -f "r%02g" 1 6`)
# ============================================================
 #3dTproject -input /clmnlab/GA/fmri_data/preproc_data/GA01/pb04.GA01.r01.scale+tlrc \
 #			-prefix /clmnlab/GA/Connectivity/data/bp04_run1to3/bp04.GA01.r01.scale+tlrc \
 #			-polort 4 \
 #			-mask /clmnlab/GA/Connectivity/mask/full_mask.GAGB25+tlrc \
 #			-passband 0.01 0.1
# ============================================================
dir_root=/Volumes/clmnlab/GA
dir_data=$dir_root/Connectivity/data/bp04_run1to3
dir_roi=/Users/clmn/Desktop/GA/fmri_data/rois

dir_output=/Users/clmn/Desktop/GA/tsmean/bp04
# ============================================================
find $dir_output -type f -size 0 -delete
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
## mask files
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
 #foreach mask in $masks
 #	echo $mask
 #	if [ -e $mask ]; then
 #		echo "exists"
 #	else
 #		echo "not exists"
 #	fi
 #end
# ============================================================
foreach nn in $list_nn
	foreach gg in 'GA' 'GB'
		subj=$gg$nn
		foreach run in $list_run
			datum=bp04.$subj.$run.scale+tlrc.HEAD
			if [ ! -e $dir_data/$datum ]; then
				echo "$datum does not exist!"
				continue
			fi
			aa=0
			foreach mask in $masks
				aa=$[$aa+1]

				region=$regions[$aa]

				dir_fin=$dir_output/$region
				if [ ! -d $dir_fin ]; then
					mkdir -p -m 755 $dir_fin
				fi

				fin=tsmean.bp.pb04.$subj.$run.$region.1D
				if [ ! -e $dir_fin/$fin ]; then
					echo "Calculating $subj $run $region ..."
					3dmaskave -quiet -mask $mask $dir_data/$datum >$dir_fin/$fin
				fi
			end
		end
	end
end
