#!/bin/env python

import numpy as np
import pandas as pd
import sys
from os import system
from os.path import join, exists
from glob import glob
import re
from subprocess import getoutput


if ('-p' in sys.argv):
    idx = sys.argv.index('-p')
    phase = sys.argv[idx+1]

dir_csv = '/home/sungbeenpark/Github/labs/Samsung_Hospital'

dir_root = '/mnt/ext5/SMC/fmri_data'
dir_raw = join(dir_root, 'raw_data/%s'%phase)
dir_preproc = join(dir_root, 'preproc_data/%s.anaticor/with_FreeSurfer'%phase)

df = pd.read_csv(join(dir_csv, 'SMC_IDs.csv'), sep=',', index_col=None)

## check a validation
list_dname = sorted(glob(join(dir_raw, 'S??_*')))
for subj in df.tms_id:
    dname = [s for s in list_dname if subj in s]
    if not dname:
        print("%s : %s.T1.nii (False), %s.func.nii (False)"%(subj, subj, subj))
        continue
    exist_T1 = exists(join(dir_raw, dname[0], "%s.T1.nii"%subj))
    exist_epi = exists(join(dir_raw, dname[0], "%s.func.nii"%subj))
    if exist_epi:
        info = str(getoutput("3dinfo %s | grep 'Number of time steps = ...'"%join(dir_raw, dname[0], "%s.func.nii"%subj)))
        ts = re.findall(r'\d+', info.split('\n')[1])
        print("%s : %s.T1.nii (%s), %s.func.nii (%s, t%s)"%(subj, subj, exist_T1, subj, exist_epi, ts[0]))
    else:
        print("%s : %s.T1.nii (%s), %s.func.nii (%s)"%(subj, subj, exist_T1, subj, exist_epi))

## check an absence
list_dname = sorted(glob(join(dir_preproc, 'S??')))
list_=[]
for subj in df.tms_id:
    cnt = 0
    for dname in list_dname:
        if subj in dname:
            cnt += 1
    if cnt == 0:
        list_.append(subj)
            
print(list_)
