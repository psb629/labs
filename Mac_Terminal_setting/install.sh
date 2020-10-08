#!/bin/bash

#### gcc and Xcode ####
brew install gcc

#### Homebrew ####
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#### Git ####
brew install git
mkdir ~/Github
cd ~/Github
git clone https://github.com/psb629/labs.git
git config --global user.name "psb629"
git config --global user.email "psb629@gmail.com"
git remote remove origin
git remote add origin https://’psb629’:’na6607!!MS’@github.com/psb629/labs.git

#### python ####
#brew install python

#### Anaconda ####
brew cask install anaconda
# add anaconda3 folder to our shell path
echo 'export PATH=$PATH:/usr/local/anaconda3/bin' >> ~/.zshrc
source ~/.zshrc
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


