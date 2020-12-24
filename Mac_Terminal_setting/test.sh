#!/bin/bash

git_dir=~/Desktop/Github/labs
cd $git_dir
git init
git config --global user.name "psb629"
git config --global user.email "psb629@gmail.com"
git remote remove origin
#git remote add origin https://'psb629':'na6607!!MS'@github.com/psb629/labs.git
git_id=psb629
git_password=3d37784bdd7f15f8a57346acf3a9a70c5ed603ec # personal access token
git_password=c017cdfe7fe41e26b290d108ed4639d5d2c00d3e # personal access token
git remote add origin https://"$git_id":"$git_password"@github.com/psb629/labs.git
git pull origin master

echo `date` >>$git_dir/Mac_Terminal_setting/README.txt
git add $git_dir/Mac_Terminal_setting/README.txt
git commit -m "ran test.sh"
git push -u origin master
