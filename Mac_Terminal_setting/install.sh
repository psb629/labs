#!/bin/bash

#### Homebrew ####
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#### python ####
#brew install python

#### Anaconda ####
# RECOMMENDED: Verify data integrity with SHA-256. For more information on hash verification, see cryptographic hash validation
shasum -a 256 ~/SHA-256
# Install for Python 3.7 or 2.7
bash ~/Downloads/Anaconda3-2020.02-MacOSX-x86_64.sh
bash ~/Downloads/Anaconda2-2019.10-MacOSX-x86_64.sh
# make environment
conda create --name sampark python=3.7
# update pip
pip install --upgrade pip
# install packages
conda activate sampark
pip install numpy
pip install pandas
pip install scipy
pip install sklearn
pip install nilearn
pip install matplotlib 
pip install seaborn
pip install jupyter

#### Git ####
brew install git
