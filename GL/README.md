[subjects list]()

=========================================================

## Behav_data

### extracting reward AM2 regressors with a time shift
- [Behavior.regressor.ipynb](https://github.com/psb629/labs/blob/master/GL/scripts/Behavior.regressor.ipynb)

=========================================================

## fMRI_data

### making a group full mask
- [mk.mask.group.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/mk.mask.group.zsh) -f fraction (default=0.7)

### 1st level analysis
#### GLM
- [GLM.reward_per_trial.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/GLM.reward_per_trial.shifted.zsh) -s subject -t time_shift (default=0s) -c condition (default='On')
- [3dttest++.reward_per_trial.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dttest++.reward_per_trial.shifted.zsh) -t time_shift (default=0s)
- [extract.Rew#1_Coef.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/extract.Rew#1_Coef.shifted.zsh)  -s subject -t time_shift (default=0s) -c condition (default='On')

### extracting a BOLD signal from a voxel which has maximux beta value
- [3dTproject.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dTproject.zsh) -s subject --pb source_file (default=pb02)
- [3dExtrema.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dExtrema.zsh) -s subject -a area -R ROI --pb source_file (default=pb02)

