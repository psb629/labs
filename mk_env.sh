#!/bin/bash

env_name=vgg16

#### Anaconda ####
## update pip
pip install --upgrade pip

## make environment
conda create --name $env_name python=3
conda info --env
 #conda env list

## install packages
source activate $env_name
existence=`conda info | grep $env_name | wc -l`
if [ $existence -gt 0 ]; then
	echo "ready to pip install modules at env '${env_name}'"
	pip install -r ./modules.txt
	pip install torch==1.9.0+cu111 torchvision==0.10.0+cu111 -f https://download.pytorch.org/whl/torch_stable.html
	## generate a new kernel
	pip install ipykernel
 #	jupyter kernelspec list
	python -m ipykernel install --user --name $env_name --display-name $env_name
else
	echo "pip install modules at env '${env_name}' is failed"
fi
