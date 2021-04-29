#!/bin/bash

 #git_dir=~/Github/labs
 #cd $git_dir
 #git init
 #git config --global user.name "psb629"
 #git config --global user.email "psb629@gmail.com"
 #git remote remove origin
 #git_id=psb629
 #aaa=69c34aad789ae9
 #bbb=72275d2ca4785
 #ccc=660d8e0d9aac8
 #git_password=${aaa}${bbb}${ccc} # personal access token
 #git remote add origin https://"$git_id":"$git_password"@github.com/psb629/labs.git
 #git pull origin master
 #
 #echo `date` >>$git_dir/Mac_Terminal_setting/README.txt
 #git add $git_dir/Mac_Terminal_setting/README.txt $git_dir/Mac_Terminal_setting/test.sh
 #git commit -m "ran test.sh"
 #git push -u origin master

#### Anaconda ####
## to uninstall anaconda clearly
sudo uninstall file:///Applications/Anaconda-Navigator.app/
sudo rm -rf /usr/local/anaconda3
sudo rm -rf /usr/local/Caskroom/anaconda
sudo rm -rf /usr/local/anaconda3 /Users/clmnlab/.conda
echo "uninstalling anaconda is completed"
## installation
brew install anaconda
source ~/.zshrc
## make environment
env_name=sampark
conda create --name $env_name python=3.7
conda info --env
## remove enviroment
 #conda remove --name $env_name --all
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
	pip install tables
	pip install nibabel
	pip install Cython
	pip install pycortex
 #	pip install nltk
 #	pip install tikreg
	## generate a new kernel
	python -m ipykernel install --user --name $env_name --display-name $env_name
	## check the package installing
	pip freeze
else
	echo "pip install modules at env '${env_name}' is failed"
fi
