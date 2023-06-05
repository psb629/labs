[subjects list](https://docs.google.com/spreadsheets/d/1CHrMf4PZVMOKx0OU1QyDeHqPXUr98Q3Y/edit?usp=sharing&ouid=113558884998217828683&rtpof=true&sd=true)

=========================================================
### Install NVIDIA driver
1. Detech the model of NVIDIA card and the recommended driver for it
	```
	$ ubuntu-drivers devices
	```

2. Install recommended driver
	```
	$ sudo ubuntu-drivers autoinstall
	```
	```
	Note: only do this if your currently installed driver is not the same as the recommended driver.
	```
	If you whish to install some other driver and not the recommended one, you can use the `apt` command to install your desired NVIDIA drivers.
	```
	$ sudo apt install nvidia-driver-???
	```

3. Reboot your system
	```
	$ sudo reboot
	```

### Check softwares
- An architecture name of a graphic card 
	```
	dpkg -s libc6 | Arch
	```

- A version of Ubuntu
	```
	lsb_release -a
	```

- A version of NVIDIA Driver & CUDA
	```
	$ nvidia-smi
	```

- A version of python3
	```
	$ python3 --version
	```

- A version of pytorch
	```
	$ python3 -m pip list | grep torch
	```

### Install pytorch
1. 

2. Install a pytorch package
	```
	conda install pytorch==1.8.1 torchvision==0.9.1 torchaudio==0.8.1 cudatoolkit=11.3 -c pytorch -c conda-forge
	```

=========================================================

## Behav_data

### resize screen shots for use as input data to ML-agent
- [resize_images.py](https://github.com/psb629/labs/blob/master/DRN/scripts/resize_images.py) -s subject

=========================================================

## fMRI_data

### preprocessing

- [s1.convert_DICOM.zsh](https://github.com/psb629/labs/blob/master/DRN/scripts/s1.convert_DICOM.zsh) -s subject
- [s2.create_proc.zsh](https://github.com/psb629/labs/blob/master/DRN/scripts/s2.create_proc.zsh) -s subject

- [s3.3dTproject.zsh](https://github.com/psb629/labs/blob/master/DRN/scripts/s3.3dTproject.zsh) -s subject

- [mk.mask.group.zsh](https://github.com/psb629/labs/blob/master/DRN/scripts/mk.mask.group.zsh)

### GLM

### Encoding Model
Calculate the correlation between the precomputed voxel-wise BOLD raw signal and the predicted signal.
- [calc_corr.zsh](https://github.com/psb629/labs/blob/master/DRN/scripts/calc_corr.zsh) -s subject -l layer -r run
- [calc_corr.3dttest++.zsh](https://github.com/psb629/labs/blob/master/DRN/scripts/calc_corr.3dttest++.zsh) -s subject -l layer
