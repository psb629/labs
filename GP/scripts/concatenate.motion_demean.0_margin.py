#!/bin/env python

## When using GLM, I want to calculate the head motion regressor one at a time, thus I extend the length of each regressor and set the value of the extended margin to zero.

import numpy as np
from os.path import join
import sys

## ==================================================== ##
## arg #1: subject ID
if ('-s' in sys.argv):
    idx = sys.argv.index('-s')
elif ('--subj' in sys.argv):
    idx = sys.argv.index('--subj')
subj = sys.argv[idx+1]

## arg #2: set a root directory
if ('--dir_preproc' in sys.argv):
    idx = sys.argv.index('--dir_preproc')
dir_preproc = str(sys.argv[idx+1])
## ==================================================== ##
dir_output = dir_preproc

full = np.loadtxt(join(dir_preproc,'motion_demean.%s.1D'%subj), delimiter=' ')

## Fill margin with 0
for run in range(3):
    orig = np.loadtxt(
            join(dir_preproc,'motion_demean.%s.r%02d.1D'%(subj,run+1))
            , delimiter=' '
            )
    converted = np.zeros(full.shape)
    converted[1096*run:1096*(run+1),:] = orig
    np.savetxt(
            join(dir_output,"motion_demean.%s.r%02d.0_margin.1D"%(subj,run+1)), converted
            , fmt='%f', delimiter=' ', newline='\n'
            )
