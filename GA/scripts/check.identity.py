#!/usr/bin/env python

import os
from os.path import join
import glob
from tqdm import tqdm

import numpy as np

nframe = 75
dir_pca = '/Users/clmn/Google Drive/내 드라이브/GA/results/activations/vgg16/pca'

subj = '01'

temp = []
for run in ['r01', 'r02', 'r03']:
    for layer in ['layer%02d'%(l+1) for l in range(13)]:
        temp.append((run, layer))

list_ = []
for i, (a, b) in enumerate(temp):
    for c, d in temp[i+1:]:
        list_.append((a,b,c,d))
list_ = np.array(list_)

for r1,l1,r2,l2 in tqdm(list_):
    a = np.load(join(dir_pca, subj, '%s.%s.nframe%03d.npy'%(r1, l1, nframe)))
    b = np.load(join(dir_pca, subj, '%s.%s.nframe%03d.npy'%(r2, l2, nframe)))

    if np.array_equal(a, b):
        print("%s.%s == %s.%s"%(r1,l1,r2,l2))
