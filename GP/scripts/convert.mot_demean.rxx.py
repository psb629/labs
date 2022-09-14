#!/bin/python

## When using GLM, I want to calculate the head motion regressor one at a time, thus I extend the length of each regressor and set the value of the extended margin to zero.

import numpy as np
from os.path import join
import sys

subj = sys.argv[1]
dir_root = "/mnt/ext6/GP/fmri_data/preproc_data/%s/day2/preprocessed"%subj
dir_output = dir_root

full = np.loadtxt(join(dir_root,'motion_demean.%s.1D'%subj), delimiter=' ')

for run in range(3):
    orig = np.loadtxt(
            join(dir_root,'motion_demean.%s.r%02d.1D'%(subj,run+1))
            , delimiter=' '
            )
    converted = np.zeros(full.shape)
    converted[1096*run:1096*(run+1),:] = orig
    np.savetxt(
            join(dir_output,"mot_demean.%s.r%02d.1D"%(subj,run+1)), converted
            , fmt='%f', delimiter=' ', newline='\n'
            )
