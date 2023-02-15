[subjects list]()

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

### Check a version of NVIDIA
	```
	$ nvidia-smi
	```

### Install pytorch
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

### GLM
