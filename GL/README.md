[subjects list]()

=========================================================

## Behav_data


=========================================================

## fMRI_data

### preprocessing
- [3dTproject.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dTproject.zsh) -s subject

### making a group full mask
- [mk.mask.group.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/mk.mask.group.zsh) -f fraction (default=0.7)

### 1st level analysis
#### GLM
- [GLM.reward_per_trial.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/GLM.reward_per_trial.shifted.zsh) -s subject -t time_shift (default=0s)

### extracting a BOLD signal from a voxel which has maximux beta value
- [3dExtrema.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dExtrema.zsh) -s subject

### group analysis (2nd level analysis)
#### GLM
- [3dttest++.reward_per_trial.shifted.zsh](https://github.com/psb629/labs/blob/master/GL/scripts/3dttest++.reward_per_trial.shifted.zsh) -t time_shift (default=0s)

