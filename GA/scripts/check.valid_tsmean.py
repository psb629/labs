#!/usr/bin/env python

import os
from os.path import join, exists
from glob import glob

import numpy as np

from tqdm import tqdm

import mydef
####################################################
GA = mydef.GA()
####################################################
 #list_ = glob(join('/Users/clmn','temp','*.nii*'))
 #rois = []
 #for s in list_:
 #    tmp = s.split('/')[-1].split('.nii')[0].split('.roi.GA.')
 #    if tmp[0]=='fan':
 #        tmp = ['fan'+tmp[1]]
 #    elif 'bp_demean' in tmp[0]:
 #        continue
 #    rois.append(np.array(tmp[0]))
 #rois = np.array(rois)
 #rois.sort()
 #np.save(join('/Users/clmn','temp', 'rois.npy'), rois)

####################################################
rois = np.load(join('/Users/clmn','temp', 'rois.npy'))
print(rois)
####################################################

gg = 'GA'
runs = ['r%02d'%(i+1) for i in range(6)]

list_ = []
for subj in GA.list_subj:
    for run in runs:
        for roi in rois:
            list_.append([subj,run,roi])
####################################################

cnt = 0
for subj, run, roi in tqdm(list_):
    a = join(GA.dir_stats,'GLM.MO','tsmean.backup',roi,'tsmean.bp_demean.errts.MO.%s.%s.%s.1D'%(gg+subj,run,roi))
    b = join('/Users/clmn','temp',roi,'tsmean.bp_demean.errts.MO.%s.%s.%s.1D'%(gg+subj,run,roi))
    if exists(a) and exists(b):
        a = GA.load_tsmean_1D(fname=a)
        b = GA.load_tsmean_1D(fname=b)
        if not np.array_equal(a,b):
            print(subj, run, roi)
    else:
        cnt += 1
print("Pass: %d"%cnt)
