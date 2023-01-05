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

dir_reg = join(dir_behav, 'regressors/move-stop')
makedirs(dir_reg, exist_ok=True)

fname = join(dir_behav, '%s-Cali.mat'%subj)
datum = scipy.io.loadmat(fname)
list_onsettime = datum['LearnTrialStartTime'][0]*0.001

Move = []
Stop = []
for ii, onsettime in enumerate(list_onsettime):
    if ii%2==0:
        ## Move
        Move.append('%.1f:60.0'%onsettime)
    else:
        ## Stop
        Stop.append('%.1f:60.0'%onsettime)

## save it
np.savetxt(
    join(dir_reg,'%s.Move.1D'%(subj)), Move, fmt='%s'
    , newline=' '
)
np.savetxt(
    join(dir_reg,'%s.Stop.1D'%(subj)), Stop, fmt='%s'
    , newline=' '
)
