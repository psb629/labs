[subjects list](https://docs.google.com/spreadsheets/d/1ZvJCnk1qB8B8aktyndHkCmmA336e17J_/edit?usp=sharing&ouid=113558884998217828683&rtpof=true&sd=true)

=========================================================

## fMRI_data

### preprocessing
[s1.convert.dcm2nifti.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s1.convert.dcm2nifti.zsh) -s subject -p phase

[s2-i.create.proc.anaticor_without_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s2-i.create.proc.anaticor_without_FreeSurfer.zsh) -s subject -p phase

[s2-ii.create.proc.anaticor_with_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s2-ii.create.proc.anaticor_with_FreeSurfer.zsh) -s subject -p phase

[s3.run.afni_proc.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s3.run.afni_proc.zsh) -p phase -F from_FreeSurfer (default=yes)

### Check the validation
[check.absence.py](https://github.com/psb629/labs/blob/master/SMC/scripts/check.absence.py) -p phase

### Whole Brain Correlation

- Make a group mask

[a1.3dmask_tool.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a1.3dmask_tool.zsh) -f fraction (default=0.7)

- Make an ROI mask

[a2.3dUndump.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a2.3dUndump.zsh) -r radius (default=3) -f -fraction (default=0.7) -R ROI

- Calculate Pearson's correlation

[a3.3dTcorr1D.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a3.3dTcorr1D.zsh) -R ROI -s subject -o phase -r radius (default=3) -G RemoveGlobalSignal (default=false) -f fraction (default=0.7)

([print.group.py](https://github.com/psb629/labs/blob/master/SMC/scripts/print.group.py) is necessary!) [a4.3dttest++.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a4.3dttest++.zsh) -R ROI -G RemoveGlobalSignal (default=false) -f fraction (default=0.7)
