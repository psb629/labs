#!/bin/bash

#### zsh ####
# which zsh
# chsh -s /usr/bin/zsh
# chsh -s /bin/zsh

#### oh-my-zsh ####
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# my favorite theme is amuse

#### vim ####
cd ~
curl -O https://raw.githubusercontent.com/psb629/labs/master/Mac_Terminal_setting/.vimrc
theme_dir=~/.vim/colors
if [ ! -d $theme_dir ]; then
	mkdir -p $theme_dir
fi
cd $theme_dir
curl -O https://raw.githubusercontent.com/psb629/labs/master/Mac_Terminal_setting/.vim/colors/jellybeans.vim
source ~/.vimrc

#### Homebrew ####
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

#### gcc and Xcode ####
brew install gcc

#### Git ####
brew install git
mkdir ~/Github
cd ~/Github
git clone https://github.com/psb629/labs.git
#git clone https://github.com/clmnlab/labs.git
cd ~/Github/labs
git config --global user.name "psb629"
git config --global user.email "psb629@gmail.com"
git remote remove origin
git remote add origin https://’psb629’:’na6607!!MS’@github.com/psb629/labs.git

#### python 3 ####
brew install python

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
pip install statsmodels

#### XQuartz ####
brew cask install xquartz

#### afni ####
cd ~
curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries
tcsh @update.afni.binaries -local_package PATH_TO_FILE/macos_10.12_local.tgz -do_extras
cp $HOME/abin/AFNI.afnirc $HOME/.afnirc
rm ~/@update.afni.binaries
#mv $HOME/.afni/help/all_progs.COMP.bash $HOME/.afni/help/all_progs.COMP.bash~

