#!/bin/bash

git_dir=~/Github/labs
cd $git_dir
git init
git config --global user.name "psb629"
git config --global user.email "psb629@gmail.com"
git remote remove origin
#git remote add origin https://'psb629':'na6607!!MS'@github.com/psb629/labs.git
git_id=psb629
aaa=69c34aad789ae9
bbb=72275d2ca4785
ccc=660d8e0d9aac8
git_password=${aaa}${bbb}${ccc} # personal access token
echo $git_password
git remote add origin https://"$git_id":"$git_password"@github.com/psb629/labs.git
git pull origin master

echo `date` >>$git_dir/Mac_Terminal_setting/README.txt
git add $git_dir/Mac_Terminal_setting/README.txt $git_dir/Mac_Terminal_setting/test.sh
git commit -m "ran test.sh"
git push -u origin master
