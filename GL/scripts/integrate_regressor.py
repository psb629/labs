#!/bin/python

import numpy as np
from os.path import join
from glob import glob
import re

dir_root = '/mnt/sdb2/GL/fmri_data'
dir_reg = '/mnt/sda2/GL/behav_data/regressors'
dir_output = dir_reg

 #coord = 'orig'
 #list_FB = glob(join(dir_root, 'preproc_data/GL??/%s/stimuli/GL??_RewFB.txt'%coord))
 #list_nFB = glob(join(dir_root, 'preproc_data/GL??/%s/stimuli/GL??_RewnFB.txt'%coord))
list_dir = glob(join(dir_root, 'preproc_data/GL??'))

for dir_ in list_dir:
    subj = dir_.split('/')[-1]
 #    fb = np.loadtxt(join(dir_root, 'preproc_data/%s/%s/stimuli/%s_RewFB.txt'%(subj,coord,subj)), dtype='str', delimiter=' ')
 #    nfb = np.loadtxt(join(dir_root, 'preproc_data/%s/%s/stimuli/%s_RewnFB.txt'%(subj,coord,subj)), dtype='str', delimiter=' ')
    fb = np.loadtxt(join(dir_reg, '%s_RewFB.txt'%subj), dtype='str', delimiter=' ')
    nfb = np.loadtxt(join(dir_reg, '%s_RewnFB.txt'%subj), dtype='str', delimiter=' ')
    intg = np.concatenate((fb, nfb), axis=1)
    onset_sorted = np.ones((4,145)) * np.nan
    amplitude_sorted = np.ones((4,145)) * np.nan
    AM2 = [[],[],[],[]]
    for run in range(4):
        onset = []
        amplitude = []
        
        ## remove empty elements in arraies
        for c in intg[run]:
            if c!='':
                o, a = c.split('*')
                onset.append(float(o))
                amplitude.append(float(a))
        onset = np.array(onset)
        amplitude = np.array(amplitude)

        ## sort
        idx = onset.argsort()
        for i, x in enumerate(idx):
            onset_sorted[run][i] = onset[x]
            amplitude_sorted[run][i] = amplitude[x]

        ## make a sorted AM2 regressor
        AM2[run] = ['%s*%s'%(o,a) for o,a in zip(onset_sorted[run], amplitude_sorted[run])]
    AM2 = np.array(AM2)
 #    with open(join(dir_root, 'preproc_data/%s/%s/stimuli/%s_Rew.txt'%(subj,coord,subj)), 'w') as fw:
    with open(join(dir_reg, '%s_Rew.txt'%subj), 'w') as fw:
        for run in range(4):
            for element in AM2[run]:
                fw.write(element + ' ')
            fw.write('\n')
