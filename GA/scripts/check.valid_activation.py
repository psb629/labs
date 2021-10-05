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
dir_activation = join(GA.dir_work,'results','activations','vgg16')
####################################################
subj = '01'
gg = 'GB'
runs = ['r%02d'%(i+1) for i in range(3)]
trials = ['trial%02d'%(i+1) for i in range(97)]
layers = ['layer%02d'%(i+1) for i in range(13)]
nframe = 75

list_ = []
for run in runs:
    for trial in trials:
        for layer in layers:
            list_.append([run,trial,layer])
 #####################################################
cnt = 0
for run, trial, layer in tqdm(list_):
    a = join(dir_activation, subj, '%s.%s.%s.%s.nframe%03d.npy'%(gg+subj,run,trial,layer,nframe))
    b = join(dir_activation, '%s.backup'%subj, 'late_practice.%s.%s.%s.nframe%03d.npy'%(run,trial,layer,nframe))
    if exists(a) and exists(b):
        a = np.load(a)
        b = np.load(b)
        if not np.array_equal(a,b):
            rms = np.sqrt(np.mean((a-b)**2))
            print(subj, run, trial, layer, ': %g'%rms)
    else:
        cnt+=1
print("Pass: %d"%cnt)
