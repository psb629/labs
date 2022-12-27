#!/bin/env python

import numpy as np
import pandas as pd
import sys
from os.path import join
from glob import glob


if ('-p' in sys.argv):
    idx = sys.argv.index('-p')
elif ('-mni' in sys.argv):
    idx = sys.argv.index('-mni')
phase = sys.argv[idx+1]

dir_csv = '/home/sungbeenpark/Github/labs/Samsung_Hospital'

dir_root = '/mnt/ext5/SMC/fmri_data'

dir_raw = join(dir_root, 'raw_data', phase)
dir_preproc = join(dir_root, 'preproc_data', phase)
list_dname = sorted(glob(join(dir_raw, 'S??_*')))

df = pd.read_csv(join(dir_csv, 'SMC_IDs.csv'), sep=',', index_col=None)
for subj in df.tms_id:
    for dname in list_dname:
        if subj in dname:
            print(subj)
