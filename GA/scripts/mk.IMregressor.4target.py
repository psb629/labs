#!/usr/bin/env python
# coding: utf-8

import os
from os.path import join, exists
import numpy as np
import mydef

GA = mydef.GA()

output_dir = join(GA.dir_behav,'regressors','4targets')
os.makedirs(output_dir, exist_ok=True)

for subj in GA.list_subj:
    for visit in ['GA', 'GB']:
        for run in ['r01','r02','r03','r04','r05','r06']:
            # load an onset data
            onsets = []
            with open(join(GA.dir_behav,'regressors','4targets','%s%s.onset.4targets.%s.txt'%(visit,subj,run)),'r') as fr:
                for line in fr:
                    onsets = line.strip().split(' ')
            onsets = np.array(onsets).astype(np.float)
            ## make IM regressor
            dur = 5
            temp = ['%.4f:%.1f'%(onset,dur) for onset in onsets]
            ## save it to output_dir
            with open(join(output_dir,"%s%s.IMregressor.4targets.%s.txt"%(visit,subj,run)),"w") as fw:
                for element in temp:
                    fw.write(element + ' ')

