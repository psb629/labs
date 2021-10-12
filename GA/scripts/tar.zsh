#!/bin/zsh

dir_work=~/GoogleDrive/GA/results/activations/vgg16
output=~/vgg16.tar.gz

## compress
tar -zcvf $output $dir_work

## extract
tar -zxvf $output
