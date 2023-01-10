[subjects list](https://docs.google.com/spreadsheets/d/1ZvJCnk1qB8B8aktyndHkCmmA336e17J_/edit?usp=sharing&ouid=113558884998217828683&rtpof=true&sd=true)

=========================================================

## fMRI_data

### preprocessing
[s1.convert.dcm2nifti.zsh](https://github.com/psb629/labs/blob/master/Samsung_Hospital/scripts/s1.convert.dcm2nifti.zsh) -s subject -p phase

[s2-i.create.proc.anaticor_without_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/Samsung_Hospital/scripts/s2-i.create.proc.anaticor_without_FreeSurfer.zsh) -s subject -p phase

[s2-ii.create.proc.anaticor_with_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/Samsung_Hospital/scripts/s2-ii.create.proc.anaticor_with_FreeSurfer.zsh) -s subject -p phase

[s3.run.afni_proc.zsh](https://github.com/psb629/labs/blob/master/Samsung_Hospital/scripts/s3.run.afni_proc.zsh) -p phase -F from_FreeSurfer

### GLM
