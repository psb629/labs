Glove Project for group "A" and "B" (abbreviation: GA, GB)
=========================================================

- Early (GA) : Goal-directed stage
- Late (GB) : Automatic stage

data_dir = https://drive.google.com/drive/folders/1yEdRzP-z1fc78sWKCj7NQARx_5E4viL4?usp=sharing  
script_dir = https://github.com/psb629/labs/tree/master/GA/scripts

# Behavioral Analysis

## Raw Data
```zsh
(GA) $data_dir/behav_data/$subj-fmri.mat
(GB) $data_dir/behav_data/$subj-refmri.mat
```

## Analysis

### Success Rate
### Aspect Ratio
### Transfer of Learning
### Head Motion Displacement
### Overall Movement - Success Rate Analysis
### Trajectory Visualization

# fMRI Analysis

## GLM results

1. move-stop

2. disp_14sensors

3. displacement

4. 4targets

5. rewards

## ROIs

- localizer
	![roi_7localizer](https://github.com/psb629/labs/blob/master/GA/images/20210721_rois.7localizers.png)
	- 목록
		- `left M1` : nvoxels=200
		- `right Cerebellum IV-V` : nvoxels=200
		- `right M1` : nvoxels=200
		- `left Putamen` : nvoxels=200
		- `right SMA` : nvoxels=200
		- `right Cerebellum VIIIb` : nvoxels=200
		- `left Thalamus` : nvoxels=200

	- 방식
		- Localizer scan 에서 GLM.move-stop 을 그룹 통계 분석한다.
		```zsh
		$data_dir/fMRI_data/stats/GLM.move-stop/group.statMove.tval.nii.gz
		```
		- p < 1e-5 로 thresholding 할 때 나온 7 개 cluster 를 기준으로 NN3 기준 n=200 혹은 그보다 조금 큰 cluster 가 되도록 조정하여 cluster mask 를 만들고 n>200 인 cluster 는 따로 작업하여 n=200 에 맞춘다.
		```zsh
		$data_dir/fMRI_data/stats/GLM.move-stop/Clust_mask.localizer.p1e-5.nii.gz
		$data_dir/fMRI_data/stats/GLM.move-stop/Clust_mask_000?+tlrc.BRIK.gz
		$data_dir/fMRI_data/stats/GLM.move-stop/Clust_mask_000?+tlrc.HEAD
		```
	- 코드\
	https://github.com/psb629/labs/tree/master/GA/scripts/GLM.move-stop.sh
	https://github.com/psb629/labs/tree/master/GA/scripts/mk.mask.localizer.sh

	- 데이터
		```zsh
		$data_dir/fMRI_data/roi/localizer
		```

- spherical nodes of DMN (![r=10](https://latex.codecogs.com/gif.latex?\bg_black&space;r=10)mm)
	![roi_DMN](https://github.com/psb629/labs/blob/master/GA/images/20210721_rois.DMN.png)
	- 목록
		- `Core` : nvoxels=760
			- `anteromedial frontal cortex (aMPFC)` : nvoxels=203
			- `posterior cingulate (PCC)` : nvoxels=203

		- `Medial Temporal Lobe (MTL)` : nvoxels=1766
			- `retrosplenial cortex (RSP)` : nvoxels=203
			- `(posterior) parahippocampal cortex (PHC)` : nvoxels=203
			- `posterior inferior parietal lobe (pIPL)` : nvoxels=L187, R170
			- `ventromedial preforntal cortex (vmPFC)` : nvoxels=191
			- `(anterior) parahippocampal gyrus (HF)` : nvoxels=203

		- `dorsomedial sub-regions (dmsub)` : nvoxels=1166
			- `dorsomedial prefrontal cortex (dmPFC)` : nvoxels=203
			- `lateral temporal lobe (LTC)` : nvoxels=L196, R193
			- `temporoparietal junction (TPJ)` : nvoxels=L203, R202
			- `middle temporal pole (tempP)` : nvoxels=L79, R90
	- 코드\
	https://github.com/psb629/labs/blob/master/GA/scripts/DMN_ROImasks.sh
	https://github.com/psb629/labs/tree/master/GA/scripts/DMN_ROImasks2.sh
	https://github.com/psb629/labs/tree/master/GA/scripts/DMN_ROImasks3.sh

	- 데이터
		```zsh
		$data_dir/fMRI_data/roi/DMN
		```
	- 최종 결과에서는 모듈 별로 하나로 합친 ROI 를 사용하였음

- Visual (occipital) area
	![roi_Yeo1](https://github.com/psb629/labs/blob/master/GA/images/20210721_rois.Yeo1.png)
	- 목록
		- `fusiform gyrus, BA37 (FuG_3_2)` : nvoxels=L333, R297
		- `lingual gyrus, caudal (MVOcC_5-1)` : nvoxels=L200, R244
		- `cuneus gyrus, caudal (MVOcC_5-3)` : nvoxels=L274, R216
		- `right lingual gyrus, rostral (MVOcC_5-4)` : nvoxels=358
		- `middle occipital gyrus (LOcC_4-1)` : nvoxels=L320, R333
		- `occipital polar cortex (LOcC_4-3)` : nvoxels=L416, R436
		- `inferior occipital gyrus (LOcC_4-4)` : nvoxels=L426, R359
		- `left lateral superior occipital gyrus (LOcC_2-2)` : nvoxels=251
	- 방식
		```
		$data_dir/fMRI_data/roi/fan_cluster_net_20200121.csv
		```
		기준 Yeo_17network 에서 값이 1인 ROI만 골라서 사용. https://onlinelibrary.wiley.com/doi/full/10.1002/hbm.24336 논문에서는 central visual 이라고 이야기함.
	- 데이터
		```zsh
		$data_dir/fMRI_data/roi/fan280
		```
	- 최종 결과에서는 이를 모두 하나로 합친 ROI 만 사용하였음

## Decoding Accuracy
- Multivariate Pattern Analysis 데이터\
	https://github.com/psb629/labs/blob/master/GA/scripts/3dLSS.MO.zsh 로 얻어진 3dLSS 데이터
	```zsh
	$data_dir/fMRI_data/preproc_data/$subj/betasLSS.$subj.$run.nii.gz
	```
- 코드\
	https://github.com/psb629/labs/tree/master/GA/scripts/fMRI_analysis_decoding_accuracy.ipynb

- ROI 별
	1. Localizer
	![decoding_accuracy_7localizer](https://github.com/psb629/labs/blob/master/GA/images/20210721_decacc.7localizers.png)
		- paired t-test (rejected, ![\alpha=0.005](https://latex.codecogs.com/png.latex?\bg_black&space;\fn_cm&space;\alpha=0.005))
			- early_practice vs. late_practice
				- `n200_c1_L_Postcentral`
			- early_unpractice vs. late_unpractice\
				(None)
	---
	2. 3 subnetworks of DMN\
	우리의 가설은 DMN 이 motor adapation task 나 sequence learning task 보다도 훨씬 큰 cognitive resource를 요구하는 de novo motor task 에서 중요한 역할을 한다는 것이다.
	![decoding_accuracy_DMN](https://github.com/psb629/labs/blob/master/GA/images/20210721_decacc.DMN.png)
		- paired t-test (rejected, ![\alpha=0.005](https://latex.codecogs.com/png.latex?\bg_black&space;\fn_cm&space;\alpha=0.005))
			- early_practice vs. late_practice
				- `Core` : 
				- `dMsub_TempP_r_temp`
			- early_unpractice vs. late_unpractice\
				(None)
	---
	3. visual area
	![decoding_accuracy_Yeo1](https://github.com/psb629/labs/blob/master/GA/images/20210721_decacc.Yeo1.png)
		- paired t-test (rejected, ![\alpha=0.005](https://latex.codecogs.com/png.latex?\bg_black&space;\fn_cm&space;\alpha=0.005))
			- early_practice vs. late_practice\
				(None)
			- early_unpractice vs. late_unpractice\
				(None)

## Connectivity
task-positive 영역과 task-negative 영역간의 상호작용이 개별적인 학습성과의 변동을 어느정도 설명할 수 있는지 파악하고자 한다.

분석에 앞서 다음과 같은 regress out이 선행되었다.
* MO: An amplitude of hand motion
* RO: A reward rate

### Procedure

1. MO, RO과 함께 GLM을 하고, 결과로 얻는 residual functional signal (errts)을 detrending (`-polort` 옵션)과 band passing (`-passband` 옵션)을 한다.
	* input : 
		```zsh
		$data_dir/pb02/pb02.$subj.$run.volreg.nii.gz
		$data_dir/fMRI_data/preproc_data/$subj/motion_demean.$subj.$run.1D
		$data_dir/behav_data/regressors/rewards/$subj.${run}rew1000.GAM.1D
		```
	* script : https://github.com/psb629/labs/blob/master/GA/scripts/GLM.MO.RO.zsh
	* output : 
		```zsh
		$data_dir/fMRI_data/stats/GLM.MO.RO
		```
	1. ROI는 DMN Core 4개
		
			Core_aMPFC_r, Core_aMPFC_l, Core_PCC_r, Core_PCC_l

		그리고 1-Yeo's Network에 해당하는 Fan mask
		
			105, 106, 189, 190, 193, 194, 196, 199, 200, 203, 204, 205, 206, 209

		를 node 로 하는 average BOLD signals를 계산한다.
		
		* input :
			```zsh
			$data_dir/fMRI_data/stats/GLM.MO.RO/$subj/$subj/$subj.bp_demean.errts.MO.$run.nii.gz
			$data_dir/fMRI_data/roi/DMN/Core_*.nii
			$data_dir/fMRI_data/roi/fan280/fan.roi.GA.???.nii.gz
			```
		* script : https://github.com/psb629/labs/blob/master/GA/scripts/calc.functional_activities.zsh
		* output :
			```zsh
			$data_dir/fMRI_data/stats/GLM.MO/tsmean
			```

2. Fan mask 280개를 모두 합쳐서 whole brain mask를 만든다(full mask를 사용하지 않는 이유는 white matter를 제외시키기 위함).
	* input : 
		```zsh
		$data_dir/fMRI_data/roi/fan280/fan.roi.GA.???.nii.gz
		```
	* script : https://github.com/psb629/labs/blob/master/GA/scripts/mk.global_fan280.sh
	* output : 
		```zsh
		$data_dir/fMRI_data/roi/fan280/fan.roi.GA.all.nii.gz
		```
		![Whole Fan ROIs](https://github.com/psb629/labs/blob/master/GA/images/fan_overall.png)

	1. 위의 fan 280개를 합친 mask를 사용하여, GA, GB 피험자 30명씩 (총 60명)의 Run 01~06에 대하여 global activity 를 구함.
		* script : https://github.com/psb629/labs/blob/master/GA/scripts/calc.global_activity.zsh
		* output : 
			```zsh
			$data_dir/fMRI_data/stats/GLM.MO.RO/global_activities_within_Fan280/$subj.errts.MO.RO.$run.global_activity.1D
			```
