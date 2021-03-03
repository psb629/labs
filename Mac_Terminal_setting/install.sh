#!/bin/bash

#### zsh ####
# which zsh
# chsh -s /usr/bin/zsh
# chsh -s /bin/zsh

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
git_dir=~/Github/labs
cd $git_dir
git init
git config --global user.name "psb629"
git config --global user.email "psb629@gmail.com"
git remote remove origin
git_id=psb629
## my_token, if you write this in one line, github will delete this token
aaa=69c34aad789ae9
bbb=72275d2ca4785
ccc=660d8e0d9aac8
git_password=${aaa}${bbb}${ccc} # personal access token
git remote add origin https://"$git_id":"$git_password"@github.com/psb629/labs.git
git pull origin master

echo `date` >>$git_dir/Mac_Terminal_setting/README.txt
git add $git_dir/Mac_Terminal_setting/README.txt
git commit -m "ran install.sh"
git push -u origin master

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

#### oh-my-zsh ####
# Xcode required
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cat ~/Github/labs/Mac_Terminal_setting/.zshrc >>~/.zshrc

#### python 3 ####
brew install python
# python --version -> Python 2.x
# python3 --version -> Python -> 3.x

#### Anaconda ####
brew cask install anaconda
# add anaconda3 folder to our shell path
echo 'export PATH=$PATH:/usr/local/anaconda3/bin' >> ~/.zshrc
source ~/.zshrc
# make environment
conda create --name sampark python=3.7
conda info --env
# update pip
pip install --upgrade pip
# install packages
#conda activate sampark
source activate sampark
pip install numpy
pip install pandas
pip install scipy
pip install sklearn
pip install nilearn
pip install matplotlib 
pip install seaborn
pip install statsmodels
pip install plotly
pip install psutil
pip install pympler
# check the package installing
pip freeze

#### XQuartz ####
brew cask install xquartz

#### afni ####
# XQuartz required
cd ~
update=@update.afni.binaries
pack=macos_10.12_local
curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/$update
tcsh $update -package $pack -do_extras
cp $HOME/abin/AFNI.afnirc $HOME/.afnirc
rm ~/$update

