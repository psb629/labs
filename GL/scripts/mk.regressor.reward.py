#!/usr/bin/env python3

## ========================================================= ##
from os import makedirs
from os.path import join
from glob import glob
from tqdm import tqdm
import numpy as np
import argparse
import re
## ========================================================= ##
dir_git = '/home/sungbeenpark/Github/labs/GL'
dir_reg = join(dir_git, 'behav_data/regressors')
## ========================================================= ##
sec=4
ntrial = 12
nblock = 12
nrun=6
## ========================================================= ##
list_cond = ['on', 'off', 'test', 'main' , 'all']
## ========================================================= ##
## ArgumentParser 객체 생성
parser = argparse.ArgumentParser()

## 옵션 목록
parser.add_argument('-s','--subject', type=str, help="Subject ID")
parser.add_argument('-t','--time', type=float, default=0, help="Degree of time delay, default=0")
parser.add_argument(
        '-c','--condition',
        type=str, default='all', choices=list_cond,
        help="Experimental conditions. 'on': Display only Cursor On session, 'off': Display only Cursor Off session, 'test': Display only Test session, 'main': Display main session (Run 1-4) excluding the first trial, 'all': Display all runs including the first trial."
)
parser.add_argument(
        '-a','--apart',
        type=str, default='no', choices=['yes','no'],
        help="Generate separate txt files for each RUN (yes/no). default='no'"
)
## ========================================================= ##
## 명령줄 인자 파싱
args = parser.parse_args()

subj = args.subject
time = args.time
cond = args.condition
apart = args.apart.lower()[0]
## ========================================================= ##
dir_output = join(dir_reg, 'AM/reward/shift=%d'%time)
makedirs(dir_output, exist_ok=True)
## ========================================================= ##
if cond == 'off':
    cc = [0]
elif cond == 'on':
    cc = [1]
elif cond == 'test':
    cc = [2]
elif cond == 'main':
    cc = [0,1]
elif cond == 'all':
    cc = [-1,0,1,2]
else:
    cc = [-10]
## ========================================================= ##
txt_onset = np.loadtxt(
        join(dir_reg, '%s.onsettime.txt'%subj),
        dtype='float', delimiter=None
)
txt_reward = np.loadtxt(
        join(dir_reg, '%s.reward.txt'%subj),
        dtype='str', delimiter=None
)
txt_cond = np.loadtxt(
        join(dir_reg, 'main.condition.txt'),
        dtype='int', delimiter=None
)
## ========================================================= ##
reg = np.empty((nrun, ntrial*nblock+1), dtype='U15')
for r in range(nrun): 
    for t, (onset, reward, c) in enumerate(zip(txt_onset[r], txt_reward[r], txt_cond[r])):
        if not c in cc:
            continue
        reg[r,t] = '%.3f*%s'%(onset+time,reward)
 #print(reg)
reg_cut = []
for rr in reg:
    tmp = rr[rr!='']
    if len(tmp)!=0:
        reg_cut.append(tmp)
reg_cut = np.array(reg_cut)
 #print(reg_cut, reg_cut.shape)
## ========================================================= ##
if apart=='n':
    np.savetxt(
        join(dir_output,'%s.reward.shift=%d.%s.rall.txt'%(subj,time,cond)),
        X=reg_cut,
        fmt='%s', delimiter=' ', newline='\n'
    )
elif apart=='y':
    for ii, rr in enumerate(reg_cut):
        np.savetxt(
            join(dir_output,'%s.reward.shift=%d.%s.r%02d.txt'%(subj,time,cond,ii+1)),
            X=rr,
            fmt='%s', delimiter=' ', newline=' '
        )
## ========================================================= ##
