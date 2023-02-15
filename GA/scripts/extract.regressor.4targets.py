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
idx = False
if ('-s' in sys.argv):
    idx = sys.argv.index('-s')
elif ('--subj' in sys.argv):
    idx = sys.argv.index('--subj')
subj = sys.argv[idx+1]
gg, nn = subj[:2], subj[2:]

## arg #2: time shift
idx = False
if ('-t' in sys.argv):
    idx = sys.argv.index('-t')
elif ('--time_shift' in sys.argv):
    idx = sys.argv.index('--time_shift')
shift = float(sys.argv[idx+1]) if idx else 0
## ==================================================== ##
dir_root = '/mnt/ext5/GA'
dir_behav = join(dir_root, 'behav_data')

dir_reg = join(dir_behav, 'regressors/IM/4targets')
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
nrun = 6
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
def onset_times(datum):
    spt = 5
    nS = int(datum['nSampleTrial'][0][0]) # 5 s * 60 Hz = 300 samples
    assert spt*60==nS

    ntrial = 12
    nblock = 8
    assert 1+ntrial*nblock==tpr

    ## onset times
    onsettime = datum['LearnTrialStartTime'][0]
    tmp = np.where(np.diff(onsettime)<0)[0]
    idx_endpoint = tmp[:nrun] if tmp.shape[0]>=nrun else np.concatenate(([-1],tmp))
    tmp = np.zeros((nrun, tpr), dtype=float)
    for run, idx_end in enumerate(idx_endpoint):
        tmp[run,:] = onsettime[idx_end+1:idx_end+1+tpr]*0.001
    onsettime=tmp
    assert ~(onsettime==0).sum()

    ## target ID
    tmp = datum['targetID'][0]
    targetID = tmp[tmp!=0][:tpr*nrun]    # 291 trials = 97 trial/run * 3 runs

    return targetID, onsettime
## ==================================================== ##
if gg == 'GA':
    datum = scipy.io.loadmat(join(dir_behav, 'GA%s-fmri.mat'%nn))
elif gg == 'GB':
    datum = scipy.io.loadmat(join(dir_behav, 'GA%s-refmri.mat'%nn))
else:
    quit()

targetID, onsettime = onset_times(datum)
targetID = targetID.reshape(nrun,tpr)[:,1:]
onsettime = onsettime[:,1:]

for tID in [1,5,21,25]:
    onset = onsettime[targetID==tID].reshape(6,-1)
    reg = {}
    reg['practice'] = onset[:3]
    reg['unpractice'] = onset[3:]
    for phase in ['practice','unpractice']:
        np.savetxt(
            join(dir_reg, '%s.target%02d.%s.txt'%(subj,tID,phase))
            , X=reg[phase], fmt='%.4f', delimiter=' ', newline='\n'
        )
