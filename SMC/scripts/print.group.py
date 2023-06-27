#!/bin/env python

## ========================================================= ##
import numpy as np
import pandas as pd
import sys
from os import system
from os.path import join, exists
from glob import glob
import re
from subprocess import getoutput
import argparse
## ========================================================= ##
## ArgumentParser 객체 생성
parser = argparse.ArgumentParser()

## 옵션 목록
parser.add_argument('-R','--ROI', help="ROI name")
parser.add_argument('-g','--group', help="Group name (stim or sham)")
parser.add_argument('-G','--GSR', default='false', help="Global Signal Removed (default: false)")
parser.add_argument('--dir_fmri', default="/mnt/ext5/SMC/fmri_data", help="The location of $dir_fmri (default: /mnt/ext5/SMC/fmri_data)")
## ========================================================= ##
## 명령줄 인자 파싱
args = parser.parse_args()

ROI = args.ROI
group = args.group.lower()
GSR = args.GSR
dir_fmri = args.dir_fmri
## ========================================================= ##
dir_csv = '/home/sungbeenpark/Github/labs/SMC'
dir_stat = join(dir_fmri, 'stats/correlations/%s'%ROI)
df = pd.read_csv(join(dir_csv, 'SMC_IDs.csv'), sep=',', index_col=None)
## ========================================================= ##
## load total subjects
list_pre = sorted(glob(join(dir_stat,'3dTcorr1D.%s.S??.pre.GlobalSignalRemoved=%s.Fisher.nii'%(ROI,GSR))))
list_post = sorted(glob(join(dir_stat,'3dTcorr1D.%s.S??.post.GlobalSignalRemoved=%s.Fisher.nii'%(ROI,GSR))))
## ========================================================= ##
tmp1 = []
for fname in list_pre:
    subj = fname.split('/')[-1].split('.')[2]
    tmp1.append(subj)
tmp1 = sorted(set(tmp1))
tmp2 = []
for fname in list_post:
    subj = fname.split('/')[-1].split('.')[2]
    tmp2.append(subj)
tmp2 = sorted(set(tmp2))

list_subj = np.intersect1d(tmp1, tmp2)
## ========================================================= ##
## set groups separately
list_stim=[]
list_sham=[]
for subj in list_subj:
    is_stim = bool(df.loc[df.tms_id==subj].c0_t1.values[0])
    if is_stim:
        list_stim.append(subj)
    else:
        list_sham.append(subj)
## ========================================================= ##
## print subjects from the group
if group == 'stim':
    list_subj = list_stim
elif group == 'sham':
    list_subj = list_sham

for subj in list_subj:
    print(subj, end=' ')
## ========================================================= ##
 ### return
 #if group == 'stim':
 #    res = stim
 #elif group == 'sham':
 #    res = sham
 #
 #for subj in res:
 #    print(subj, end=' ')
