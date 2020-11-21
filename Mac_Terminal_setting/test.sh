#!/bin/bash
cd ~/Github/labs
git init
git config --global user.name "psb629"
git config --global user.email "psb629@gmail.com"
git remote remove origin
git remote add origin https://'psb629':'na6607!!MS'@github.com/psb629/labs.git
git pull origin master

echo `date` >>~/Github/labs/Mac_Terminal_setting/README.txt
git add ~/Github/labs/Mac_Terminal_setting/README.txt
git commit -m "ran install.sh"
git push -u origin master
