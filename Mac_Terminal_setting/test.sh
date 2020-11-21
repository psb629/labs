#!/bin/bash

cd ~/Github/labs
git config --global user.name "psb629"
git config --global user.email "psb629@gmail.com"
git remote remove origin
git remote add origin https://’psb629’:’na6607!!MS’@github.com/psb629/labs.git
git push --set-upstream origin master
