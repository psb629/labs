env_name=GDL

conda create -n $env_name python=3.6 ipykernel

source activate $env_name
is_env_activated=`conda info | grep $env_name | wc -l`
if [ $is_env_activated -gt 0 ]; then
	echo "ready to pip install modules at env '${env_name}'"
	pip install virtualenv virtualenvwrapper
fi
