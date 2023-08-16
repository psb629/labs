[subjects list]()

=========================================================

## Importing the Anaconda virtual environment package to run Jupyter notebook.
```
conda env create -f GP.yaml
```

=========================================================

## Behav_data

### Extracting basic regressors
- [Behavior.regressor.ipynb](https://github.com/psb629/labs/blob/master/GL/scripts/Behavior.regressor.ipynb)

1. Creating reward-modulated regressors (AM2):

	- [mk.regressor.reward.py](https://github.com/psb629/labs/blob/master/GL/scripts/mk.regressor.reward.py) -h

=========================================================

## fMRI_data

### Making a group full mask
- [mk.mask.group.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/mk.mask.group.zsh) -f fraction (default=0.7)

### 1st level analysis
#### GLM
1. Move-Stop:

	- [GLM.move-stop.SSKim.tcsh](https://github.com/psb629/labs/blob/master/GL/scripts/GLM.move-stop.SSKim.tcsh) subject

2. Reward:

	- [GLM.reward_per_trial.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/GLM.reward_per_trial.shifted.zsh) -s subject -t time_shift (default=0s) -c condition (default='On')
	- [3dttest++.reward_per_trial.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dttest++.reward_per_trial.shifted.zsh) -t time_shift (default=0s)
	- [extract.Rew#1_Coef.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/extract.Rew#1_Coef.shifted.zsh)  -s subject -t time_shift (default=0s) -c condition (default='On')

### Extracting a BOLD signal from a voxel which has maximux beta value
- [3dTproject.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dTproject.zsh) -s subject --pb source_file (default=pb02)
- [3dExtrema.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dExtrema.zsh) -s subject -a area -R ROI --pb source_file (default=pb02)

