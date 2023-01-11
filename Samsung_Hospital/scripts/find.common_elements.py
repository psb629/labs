#!/bin/env python

## =============================================================== ##
import numpy as np
from os.path import join, exists
from glob import glob
import sys
## =============================================================== ##
args = sys.argv
## =============================================================== ##
## ROI
idx = args.index('-R')
ROI = args[idx+1]

## Removing Global Signal
idx = args.index('-G')
tmp = args[idx+1]
RGS = 'true' if ((tmp=='y')|(tmp=='yes')) else ( 'false' if ((tmp=='n')|(tmp=='no')) else 'invalid' )
## =============================================================== ##
dir_root='/mnt/ext5/SMC/fmri_data/stats/correlations/%s'%ROI
if not exists(dir_root):
    quit()
## =============================================================== ##
## pre
list_fname = glob(join(dir_root, "3dTcorr1D.*.S??.pre.GlobalSignalRemoved=%s.nii"%RGS))
list_pre = []
for fname in list_fname:
    subj = fname.split('/')[-1].split('.')[2]
    list_pre.append(subj)
 #list_pre.sort()

## post
list_fname = glob(join(dir_root, "3dTcorr1D.*.S??.post.GlobalSignalRemoved=%s.nii"%RGS))
list_post = []
for fname in list_fname:
    subj = fname.split('/')[-1].split('.')[2]
    list_post.append(subj)
 #list_post.sort()

list_subj = np.intersect1d(list_pre, list_post)
for subj in list_subj:
    print(subj, end=' ')
