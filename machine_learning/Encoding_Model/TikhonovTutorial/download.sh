#!/bin/zsh

download_dir=~/Downloads
root_dir=~/Github/labs/machine_learning/Encoding_Model/TikhonovTutorial
if [ ! -d $root_dir ]; then
	mkdir -p -m 755 $root_dir
fi

## download codes from Github of AlexHuth
cd $root_dir
foreach nn (`seq -f %01g 1 3`)
	curl -O https://raw.githubusercontent.com/alexhuth/TikhonovTutorial/master/${nn}_tikhonov_tutorial.ipynb
end

## download essential modules
cd $root_dir
curl -O https://raw.githubusercontent.com/alexhuth/TikhonovTutorial/master/util.py
curl -O https://raw.githubusercontent.com/alexhuth/TikhonovTutorial/master/npp.py
curl -O https://raw.githubusercontent.com/alexhuth/TikhonovTutorial/master/ridge.py
curl -O https://raw.githubusercontent.com/alexhuth/TikhonovTutorial/master/ridge_utils.py
curl -O https://raw.githubusercontent.com/alexhuth/TikhonovTutorial/master/SemanticModel.py
curl -O https://raw.githubusercontent.com/alexhuth/TikhonovTutorial/master/ridge_utils.py

## download data from my google drive
cd $download_dir
file_id=1a4xVkjyzypRNFIAVe1uePqlRlYE1hI1c
file_name=tikhonov_tutorial_data.zip
curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${file_id}" > /dev/null
code="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${code}&id=${file_id}" -o ${file_name}

zip -d $file_name "__MACOSX*"
unzip $file_name
