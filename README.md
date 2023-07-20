## 1. Install an Anaconda virtual enviroment

### 1-i. Create a new one
```
conda create --name ${env_name} python=${version}
```

### 1-ii. Import the old one
```
conda env create -f ${yaml_file}
```
---
#### cf)
- check the list
```
conda info --env
```
---
## 2. Set Jupyter Kernel
```
python -m ipykernel install --user --name ${env_name} --display-name ${env_name}
```
---
## 3. Remove an Anaconda virtual enviroment clearly

### 3-i. Enviroment
```
conda remove --name ${env_name} --all
```

### 3-ii. Juypter Kernel
```
rm -rf $HOME/.local/share/jupyter/kernels/${env_name}
```
or
```
jupyter kernelspec uninstall ${env_name}
```
