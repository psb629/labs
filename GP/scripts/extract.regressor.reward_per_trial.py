#!/bin/env python

import numpy as np
import pandas as pd
import scipy.io
from scipy import special
from scipy import optimize
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import date
from glob import glob
from os.path import join, exists
from os import makedirs
import random
from random import random as rand
from datetime import date
from tqdm import tqdm
import sys
## ==================================================== ##
## arg #1: subject ID
if ('-s' in sys.argv):
    idx = sys.argv.index('-s')
elif ('--subj' in sys.argv):
    idx = sys.argv.index('--subj')
subj = sys.argv[idx+1]

## arg #2: time shift
if ('-t' in sys.argv):
    idx = sys.argv.index('-t')
elif ('--time_shift' in sys.argv):
    idx = sys.argv.index('--time_shift')
shift = float(sys.argv[idx+1])
## ==================================================== ##
dir_root = '/mnt/ext5/GP'
dir_behav = join(dir_root, 'behav_data')

dir_reg = join(dir_behav, 'regressors/AM/%.1fs_shifted'%shift)
makedirs(dir_reg, exist_ok=True)
## ==================================================== ##
## the number of trials per run
tpr = 96+1

## second per trial
spt = 5

## frame per trial
fpt = 60*spt

## total second per run
spr = spt*tpr

## the number of runs
nrun = 3
## ==================================================== ##
def convert_ID(ID):
    ##################   ##################
    #  1  2  3  4  5 #   #        2       #
    #  6  7  8  9 10 #   #        1       #
    # 11 12 13 14 15 # = # -2 -1  0  1  2 #
    # 16 17 18 19 20 #   #       -1       #
    # 21 22 23 24 25 #   #       -2       #
    ##################   ##################
    x = np.kron(np.ones(5),np.arange(-2,3)).astype(int)
    y = np.kron(np.arange(2,-3,-1),np.ones(5)).astype(int)
    pos = np.array((x[ID-1],y[ID-1]))
    return pos
## ==================================================== ##
def func_AMregressor(datum):
    spt = 5
    nS = int(datum['nSampleTrial'][0][0]) # 5 s * 60 Hz = 300 samples
    assert spt*60==nS

    ntrial = 12
    nblock = 8
    assert 1+ntrial*nblock==tpr

    onsettime = datum['LearnTrialStartTime'][0]
    idx_editpoint = [i+1 for i,t in enumerate(onsettime[:-2]) if (onsettime[i]>onsettime[i+1])]
    assert (np.diff(idx_editpoint)==tpr).all() # Are you sure the fact that 145 trials per run?

    ## target ID
    tmp = datum['targetID'][0]
    targetID = tmp[tmp!=0][:tpr*nrun]    # 291 trials = 97 trial/run * 3 runs

    ## onset times
    tmp = np.zeros((nrun, tpr), dtype=float)
    for run in range(nrun):
        idx = idx_editpoint[run]
        tmp[run,:] = onsettime[idx:idx+tpr]*0.001
    onsettime=tmp

    ## counting how many times did they hit the target
    hit_or_not = np.zeros((tpr*nrun, nS), dtype=bool) # (# of trials/run, # if frames/trial)
    for t, ID in enumerate(targetID):
        pos = datum['boxSize']*convert_ID(ID) # r_target = [x_target, y_target]
        ## allXY.shape = (2, 60 Hz * 4 s/trial * 145 trials/run * 6 runs = 208800 frames)
        xy = datum['allXY'][:,nS*t:nS*(t+1)] # r_cursor = [x_cursor, y_cursor]
        ## err.shape = (2, nS)
        err = xy - np.ones((2,nS))*pos.T # dr = r_cursor - r_target
        ## is the cursor in the target box?
        hit_or_not[t,:] = (abs(err[0,:]) <= datum['boxSize']*0.5) & (abs(err[1,:]) <= datum['boxSize']*0.5)

    cnt_hit = hit_or_not.reshape(nrun, tpr, spt, 60).sum(axis=(2,3))

    return onsettime, cnt_hit
## ==================================================== ##
datum = scipy.io.loadmat(join(dir_behav, '%s-fmri.mat'%subj))

onsettime, cnt_hit = func_AMregressor(datum)
reward = cnt_hit/fpt

AM2 = [[],[],[]]
for run in range(nrun):
    AM2[run] = ['%.1f*%.3f'%(o,r) for o,r in zip(onsettime[run]+shift, reward[run])]

np.savetxt(
    join(dir_reg, '%s.reward.txt'%subj)
    , X=AM2, fmt='%s', delimiter=' ', newline='\n'
)
