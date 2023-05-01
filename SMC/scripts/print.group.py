#!/bin/env python

import numpy as np
import pandas as pd
import sys
from os import system
from os.path import join, exists
from glob import glob
import re
from subprocess import getoutput

## default
 #RGS = 'false'

## parameters
if ('-R' in sys.argv):
    idx = sys.argv.index('-R')
    ROI = sys.argv[idx+1]
if ('-g' in sys.argv):
    idx = sys.argv.index('-g')
    group = sys.argv[idx+1]
if ('-G' in sys.argv):
    idx = sys.argv.index('-G')
    tmp = str(sys.argv[idx+1])
    RGS = tmp
if ('--dir_fmri' in sys.argv):
    idx = sys.argv.index('--dir_fmri')
    tmp = str(sys.argv[idx+1])
    dir_fmri = tmp

dir_csv = '/home/sungbeenpark/Github/labs/SMC'

dir_stat = join(dir_fmri, 'stats/correlations/%s'%ROI)

df = pd.read_csv(join(dir_csv, 'SMC_IDs.csv'), sep=',', index_col=None)

## load total subjects
list_pre = sorted(glob(join(dir_stat, '3dTcorr1D.%s.S??.pre.GlobalSignalRemoved=%s.nii'%(ROI, RGS))))
list_post = sorted(glob(join(dir_stat, '3dTcorr1D.%s.S??.post.GlobalSignalRemoved=%s.nii'%(ROI, RGS))))

tmp1 = []
for fname in list_pre:
    subj = fname.split('/')[-1].split('.')[-4]
    tmp1.append(subj)
tmp1 = sorted(set(tmp1))
tmp2 = []
for fname in list_post:
    subj = fname.split('/')[-1].split('.')[-4]
    tmp2.append(subj)
tmp2 = sorted(set(tmp2))

list_subj = np.intersect1d(tmp1, tmp2)

## set groups separately
list_stim=[]
list_sham=[]
for subj in list_subj:
    is_stim = bool(df.loc[df.tms_id==subj].c0_t1.values[0])
    if is_stim:
        list_stim.append(subj)
    else:
        list_sham.append(subj)

## print subjects from the group
if group == 'stim':
    list_subj = list_stim
elif group == 'sham':
    list_subj = list_sham

for subj in list_subj:
    print(subj, end=' ')

 ### return
 #if group == 'stim':
 #    res = stim
 #elif group == 'sham':
 #    res = sham
 #
 #for subj in res:
 #    print(subj, end=' ')
