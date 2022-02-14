#!/bin/zsh

subj=S45
date=220106
dir_raw=~/Downloads/${subj}_${date}_MRI/DICOMDIR

dir_output=~/Desktop/${subj}_${date}

mkdir -m 755 -p $dir_output

dcm2niix_afni -f $subj -o $dir_output -p y -z n $dir_raw
