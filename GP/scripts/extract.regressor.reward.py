#!/bin/python

import numpy as np
import pandas as pd
import scipy.io
from scipy import special
from scipy import optimize
from scipy import stats
import matplotlib.pyplot as plt
import seaborn as sns
import plotly as py
import plotly.express as px
from datetime import date
from glob import glob
from os.path import join, exists
from os import makedirs
import random
from random import random as rand

from datetime import date

from tqdm import tqdm

## date
today = date.today().strftime("%Y%m%d")

dir_root = '/mnt/ext6/GP'
dir_behav = join(dir_root, 'behav_data')

dir_reg = join(dir_behav, 'regressors/AM')
makedirs(dir_reg, exist_ok=True)

list_subj = ['08', '09', '10', '11', '17'
             , '18', '19', '20', '21', '22'
             , '24', '26', '27', '32', '33'
             , '34', '35', '36', '37', '38'
             , '39', '40', '41']
list_subj = ['42', '43', '45', '46', '47', '48', '49', '50', '51']
list_subj = ['44']

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
    
    ## second per trial
    spt = 5
    ## frame per trial
    fpt = 60*spt
    ## the number of trials per run
    tpr = 96+1
    ## the number of runs
    nrun = 3

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

ntrial = 97
sec_per_trial = 5
tot_sec = sec_per_trial*ntrial

for nn in list_subj:
    subj = 'GP%s'%nn
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
        upsampled_onsettime = np.ones(tot_sec) * np.nan
        for trial in range(ntrial):
            upsampled_onsettime[trial*5] = onsettime[run][trial]
            upsampled_onsettime[trial*5 + 1] = onsettime[run][trial] + 1.
            upsampled_onsettime[trial*5 + 2] = onsettime[run][trial] + 2.
            upsampled_onsettime[trial*5 + 3] = onsettime[run][trial] + 3.
            upsampled_onsettime[trial*5 + 4] = onsettime[run][trial] + 4.
        ## ???
    #     upsampled_onsettime += 0.5
        for sec in range(tot_sec):
            trial = sec//5
            ss = sec%5
            regressor[run].append('%.2f*%.3f'%(upsampled_onsettime[sec],hit[run,trial,ss]))

    np.savetxt(
        join(dir_reg,'%s.AM.onset-reward.1D'%subj), regressor, fmt='%s'
        , delimiter=' ', newline='\n'
    )

