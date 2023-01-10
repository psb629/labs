[subjects list](https://docs.google.com/spreadsheets/d/1Nff2Vwh-_WPb08mhUoVqQHp2leh20ZHAsM6I09ljvBU/edit?usp=sharing)

=========================================================

## Behav_data

### day1 (r00)
- [extract.regressor.move-stop.py](https://github.com/psb629/labs/blob/master/GP/scripts/extract.regressor.move-stop.py) -s subject

### day2 (r01-r03)
- [extract.regressor.reward_per_1s.py](https://github.com/psb629/labs/blob/master/GP/scripts/extract.regressor.reward_per_1s.py) -s subject
- [extract.regressor.reward_per_trial.py](https://github.com/psb629/labs/blob/master/GP/scripts/extract.regressor.reward_per_trial.py) -s subject -t time_shift
- [extract.regressor.movement.py](https://github.com/psb629/labs/blob/master/GP/scripts/extract.regressor.movement.py) -s subject -t time_shift

=========================================================

## fMRI_data

### preprocessing
- [a1.convert_dcm.zsh](https://github.com/psb629/labs/blob/master/GP/scripts/a1.convert_dcm.zsh) -s subject -d day
- (test.create_proc.zsh is necessary!)[a2.preproc.zsh](https://github.com/psb629/labs/blob/master/GP/scripts/a2.preproc.zsh) -s subject -d day

### GLM
- [GLM.move-stop.zsh](https://github.com/psb629/labs/blob/master/GP/scripts/GLM.move-stop.zsh) -s subject
- [GLM.reward_per_1s.zsh](https://github.com/psb629/labs/blob/master/GP/scripts/GLM.reward_per_1s.zsh) -s subject
