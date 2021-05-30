#!/bin/zsh

git_dir=~/Github
 #cd $git_dir
 #git clone https://github.com/rickiepark/GDL_code.git

GDL_dir=$git_dir/GDL_code
 #cd $GDL_dir
 #git pull

env_name=GDL
conda create -n $env_name python=3.6 ipykernel
source activate $env_name
is_env_activated=`conda info | grep $env_name | wc -l`
if [ $is_env_activated -gt 0 ]; then
	python -m ipykernel install --user --name $env_name --display-name $env_name
	echo "ready to pip install modules at env '${env_name}'"
	pip install -r $GDL_dir/requirements.txt
fi
