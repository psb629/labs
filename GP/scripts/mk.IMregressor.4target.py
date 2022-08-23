#!/bin/python

import os
from os.path import join, exists
import numpy as np

list_subj = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15'
             ,'18', '19', '20', '21', '23', '26', '27', '28', '29', '30'
             ,'31', '32', '33', '34', '35', '36', '37', '38', '42', '44'
             , '45']

dir_root = '/mnt/sda2/GA'
dir_behav = join(dir_root, 'behav_data')

dir_output = join(dir_behav,'regressors','4targets')
os.makedirs(dir_output, exist_ok=True)

for subj in list_subj:
    for visit in ['GA', 'GB']:
        for run in ['r01','r02','r03','r04','r05','r06']:
            # load an onset data
            onsets = []
            with open(join(dir_behav,'regressors','4targets','%s%s.onset.4targets.%s.txt'%(visit,subj,run)),'r') as fr:
                for line in fr:
                    onsets = line.strip().split(' ')
            onsets = np.array(onsets).astype(np.float)
            ## make IM regressor
            dur = 5
            temp = ['%.4f:%.1f'%(onset,dur) for onset in onsets]
            ## save it to dir_output
            with open(join(dir_output,"%s%s.IMregressor.4targets.%s.txt"%(visit,subj,run)),"w") as fw:
                for element in temp:
                    fw.write(element + ' ')

