[subjects list](https://docs.google.com/spreadsheets/d/1CHrMf4PZVMOKx0OU1QyDeHqPXUr98Q3Y/edit?usp=sharing&ouid=113558884998217828683&rtpof=true&sd=true)

=========================================================

## fMRI_data

### preprocessing
[s1.convert.dcm2nifti.zsh](https://github.com/psb629/labs/blob/master/Samsung_Hospital/scripts/s1.convert.dcm2nifti.zsh) -s subject -p phase
[s2-i.create.proc.anaticor_without_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/Samsung_Hospital/scripts/s2-i.create.proc.anaticor_without_FreeSurfer.zsh) -s subject -p phase
[s2-ii.create.proc.anaticor_with_FreeSurfer.zsh](https://github.com/psb629/labs/blob/master/Samsung_Hospital/scripts/s2-ii.create.proc.anaticor_with_FreeSurfer.zsh) -s subject -p phase

### GLM
