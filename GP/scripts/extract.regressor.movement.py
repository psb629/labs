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
from sklearn.preprocessing import normalize
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
## ==================================================== ##
## load data
behav_data = join(dir_behav, '%s-fmri.mat'%subj)
datum = scipy.io.loadmat(behav_data)

## construct a movement array, then normalize it
reg_movement = []
for ii in range(tpr*nrun):
    ## movement = integral dr , i.e., integral sqrt(dx*dx + dy*dy)
    XY = datum['allXY'][:,300*ii:300*(ii+1)]
    diff = np.diff(XY, axis=1)
    tmp = np.sum(diff*diff, axis=0)
    reg_movement.append(np.sqrt(tmp).sum())
reg_movement_normalized = normalize(np.reshape(reg_movement, (-1,1)), norm='l2', axis=0).reshape(nrun,tpr)

## construct an onset time array,
tmp = datum['LearnTrialStartTime'][0]
tmp = np.diff(tmp)
idx = np.where(tmp<0)[0] + 1

onsettime = np.zeros((nrun, tpr), dtype=float)
for rr in range(nrun):
    onsettime[rr,:] = datum['LearnTrialStartTime'][0][idx[rr]:idx[rr]+tpr]
onsettime = onsettime * 0.001

## construct an AM2 regressor for movement
regressor = [[],[],[]]
for run in range(nrun):
    for trial, (onset, move) in enumerate(zip(onsettime[run], reg_movement_normalized[run])):
        regressor[run].append('%.2f*%.4f'%(onset+shift, move))

## save it
np.savetxt(
    join(dir_reg,'%s.movement.txt'%(subj)), regressor, fmt='%s'
    , delimiter=' ', newline='\n'
)
