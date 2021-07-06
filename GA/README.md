Glove Project for group "A" and "B" (abbreviation: GA, GB)
=========================================================

# Connectivity

data_dir = https://drive.google.com/drive/folders/1yEdRzP-z1fc78sWKCj7NQARx_5E4viL4?usp=sharing  
script_dir = https://github.com/psb629/labs/tree/master/GA/scripts

다음과 같은 regress out이 선행되었다.
* MO: An amplitude of hand motion
* RO: A reward rate

## Procedure

1. MO, RO과 함께 GLM을 하고, 결과로 얻는 residual functional signal (errts)을 detrending (-polort 옵션)과 band passing (-passband 옵션)을 한다.
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
		* output :
			```zsh
			$data_dir/fMRI_data/stats/GLM.MO/tsmean
			```

* Fan mask 280개를 모두 합쳐서 whole brain mask를 만든다(full mask를 사용하지 않는 이유는 white matter를 제외시키기 위함).
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

* 위의 fan 280개를 합친 mask를 사용하여, GA, GB 피험자 30명씩 (총 60명)의 Run 01~06에 대하여 global activity 를 구함.
	* script : https://github.com/psb629/labs/blob/master/GA/scripts/calc.global_activity.zsh
	* output : 
		```zsh
		$data_dir/fMRI_data/stats/GLM.MO.RO/global_activities_within_Fan280/$subj.errts.MO.RO.$run.global_activity.1D
		```
