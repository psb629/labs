#!/bin/zsh

conda install pytorch==1.8.1 torchvision==0.9.1 torchaudio==0.8.1 cudatoolkit=11.3 -c pytorch -c conda-forge
pip install mlagents==0.26.0
pip install protobuf==3.19.4
