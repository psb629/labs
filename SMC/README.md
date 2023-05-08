[subjects list](https://docs.google.com/spreadsheets/d/1ZvJCnk1qB8B8aktyndHkCmmA336e17J_/edit?usp=sharing&ouid=113558884998217828683&rtpof=true&sd=true)

[Target 분석정리](https://docs.google.com/spreadsheets/d/1eLaZn_yniFekXzYsqAXjAuyhULvQFkI2apAaMrSBi9E/edit?usp=sharing)

[TMS_로그지_220614.xlsx](https://github.com/psb629/labs/blob/master/SMC/TMS_%EB%A1%9C%EA%B7%B8%EC%A7%80_220614.xlsx) Password: 1102

=========================================================

## fMRI_data

### preprocessing
[s1.convert.dcm2nifti.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s1.convert.dcm2nifti.zsh) -s subject -p phase

[s2-i.create.proc.anaticor_without_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s2-i.create.proc.anaticor_without_FreeSurfer.zsh) -s subject -p phase

[s2-ii.create.proc.anaticor_with_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s2-ii.create.proc.anaticor_with_FreeSurfer.zsh) -s subject -p phase

[s3.run.afni_proc.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/s3.run.afni_proc.zsh) -p phase -F from_FreeSurfer (default=yes)

---

### Check the validation
[check.absence.py](https://github.com/psb629/labs/blob/master/SMC/scripts/check.absence.py) -p phase

---

### Whole Brain Correlation

- Make a group mask

[a1.3dmask_tool.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a1.3dmask_tool.zsh) -f fraction (default=0.7)

- Make an ROI mask

[a2.3dUndump.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a2.3dUndump.zsh) -r radius (default=3) -R ROI

- Calculate Pearson's correlation

[a3.3dTcorr1D.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a3.3dTcorr1D.zsh) -R ROI -s subject -o phase -r radius (default=3) -G RemoveGlobalSignal (default=false)

- Post-Pre changes were calculated for 12 participants in the stim group and 8 participants in the sham group using 3dttest++

([print.group.py](https://github.com/psb629/labs/blob/master/SMC/scripts/print.group.py) is necessary!) [a4.3dttest++.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a4.3dttest++.zsh) -R ROI -G RemoveGlobalSignal (default=false) -m mask (default='full')

- Calculation of correlation between behavioral changes of 20 subjects and functional MRI changes across the whole brain

[a5.3dTcorr1D.wholebrain.r.zsh](https://github.com/psb629/labs/blob/master/SMC/scripts/a5.3dTcorr1D.wholebrain.r.zsh) -R ROI -G RemoveGlobalSignal (default=false)

---

### Precuneus

Firstly, compute the correlation between the whole brain map and lHP for each subject (`a3.3dTcorr1D.zsh`), and perform 3dttest++ (`a4.3dttest++.zsh`) to create a precuneus cluster mask corresponding to p=0.05.

