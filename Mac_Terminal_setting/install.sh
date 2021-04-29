#!/bin/bash

#### zsh ####
 #which zsh
 #chsh -s /usr/bin/zsh
 #chsh -s /bin/zsh

#### Homebrew ####
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
## To update Homebrew, simply run:
 #brew update
 #brew upgrade

#### gcc and Xcode ####
brew install gcc

#### To solve the problem that 'xcrun: error: invalid active developer path' ####
xcode-select --install

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

echo "`users`(`ipconfig getifaddr en0`): `date`" >>$git_dir/Mac_Terminal_setting/README.txt
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
## Xcode required
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cat ~/Github/labs/Mac_Terminal_setting/.zshrc >>~/.zshrc

#### python 3 ####
brew install python
## python --version -> Python 2.x
## python3 --version -> Python -> 3.x

#### Anaconda ####
## to uninstall anaconda clearly
 #rm -rf /usr/local/Caskroom/anaconda
 #sudo rm -rf /usr/local/anaconda3 /Users/clmnlab/.conda
## installation
brew install anaconda
## add anaconda3 folder to our shell path
echo 'export PATH=$PATH:/usr/local/anaconda3/bin' >> ~/.zshrc
source ~/.zshrc
## make environment
env_name=sampark
conda create --name $env_name python=3.7
conda info --env
## update pip
pip install --upgrade pip
## install packages
 #conda activate $env_name
source activate $env_name
is_env_sampark=`conda info | grep sampark | wc -l`
if [ $is_env_sampark -gt 0 ]; then
	echo "ready to pip install modules at env '${env_name}'"
	pip install numpy
	pip install pandas
	pip install jupyter notebook
	pip install scipy
	pip install sklearn
	pip install nilearn
	pip install matplotlib 
	pip install seaborn
	pip install statsmodels
	pip install plotly
	pip install psutil
	pip install pympler
 #	pip install nltk
 #	pip install tikreg
	## generate a new kernel
	python -m ipykernel install --user --name $env_name --display-name $env_name
	## check the package installing
	pip freeze
else
	echo "pip install modules at env '${env_name}' is failed"
fi

#### XQuartz ####
brew install xquartz

#### afni ####
## XQuartz required
cd ~
update=@update.afni.binaries
pack=macos_10.12_local
curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/$update
tcsh $update -package $pack -do_extras
cp $HOME/abin/AFNI.afnirc $HOME/.afnirc
## Update AFNI to latest version
 #@update.afni.binaries -d
rm ~/$update

#### Subversion ####
 #brew install subversion

#### cmake ####
 #brew install cmake

#### llvm ####
brew install llvm
echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc
 #export LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
 #export LDFLAGS="-L/usr/local/opt/llvm/lib"
 #export CPPFLAGS="-I/usr/local/opt/llvm/include"

## checkout LLVM including related sub-projects like Clang ####
 #git clone https://github.com/llvm/llvm-project.git

