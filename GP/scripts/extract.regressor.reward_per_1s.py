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

if ('-s' in sys.argv):
    idx = sys.argv.index('-s')
elif ('--subj' in sys.argv):
    idx = sys.argv.index('--subj')
subj = sys.argv[idx+1]

dir_root = '/mnt/ext5/GP'
dir_behav = join(dir_root, 'behav_data')

dir_reg = join(dir_behav, 'regressors/AM')
makedirs(dir_reg, exist_ok=True)

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

def calc_hit(behav_data):

    datum = scipy.io.loadmat(behav_data)

    ## target ID
    tmp = datum['targetID'][0]
    targetID = tmp[tmp!=0][:tpr*nrun]

    bx = datum['boxSize'][0][0]
    pos = bx*convert_ID(targetID)
    
    ## 60 Hz * {5 s/trial * (1 trial + 12 trial/block * 8 block)}/Run * 3 Run = 87300
    allXY = datum['allXY']
    
    xFrame, yFrame = np.array([datum['xFrame'].squeeze(), datum['yFrame'].squeeze()]).astype(int)
    
    ## target position
    tmp = np.zeros(allXY.shape)
    for i in range(fpt*tpr*nrun):
        t = np.floor(i/fpt).astype(int)
        tmp[0][i], tmp[1][i] = pos[0][t], pos[1][t]

    ## Is it hit?
    err = allXY - tmp
    hit = np.zeros(fpt*tpr*nrun)
    for i in range(fpt*tpr*nrun):
        hit[i] = abs(err[0][i]) <= bx*.5 and abs(err[1][i]) <= bx*.5
        
    return hit

## reward per second
hit = calc_hit(join(dir_behav, '%s-fmri.mat'%subj))
tmp = hit.reshape((3,97,5,60))
hit = np.mean(tmp, axis=3)

## load onset times
datum = scipy.io.loadmat(join(dir_behav, '%s-fmri.mat'%subj))
onsettime = np.ones((3,97)) * np.nan
tmp = datum['LearnTrialStartTime'][0]
ii = 1
while tmp[ii-1]<tmp[ii]:
    ii += 1

regressor = [[],[],[]]
for run in range(3):
    onsettime[run] = tmp[ii+97*run:ii+97*(run+1)] / 1000.
    ## upsampling
    upsampled_onsettime = np.ones(spr) * np.nan
    for trial in range(tpr):
        upsampled_onsettime[trial*5] = onsettime[run][trial]
        upsampled_onsettime[trial*5 + 1] = onsettime[run][trial] + 1.
        upsampled_onsettime[trial*5 + 2] = onsettime[run][trial] + 2.
        upsampled_onsettime[trial*5 + 3] = onsettime[run][trial] + 3.
        upsampled_onsettime[trial*5 + 4] = onsettime[run][trial] + 4.
    ## adjust onset times
#     upsampled_onsettime += 0.5
    for sec in range(spr):
        trial = sec//5
        ss = sec%5
        regressor[run].append('%.2f*%.3f'%(upsampled_onsettime[sec],hit[run,trial,ss]))

np.savetxt(
    join(dir_reg,'%s.AM.onset-reward.1D'%subj), regressor, fmt='%s'
    , delimiter=' ', newline='\n'
)

