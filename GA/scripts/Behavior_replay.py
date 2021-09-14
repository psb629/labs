#!/usr/bin/env python
import numpy as np
import pandas as pd
import scipy.io
from scipy import special
from scipy import optimize
from scipy import stats
import matplotlib.pyplot as plt
from matplotlib import patches
from matplotlib import animation, rc
import seaborn as sns
import plotly as py
import plotly.express as px
from datetime import date
from glob import glob
from os.path import join, dirname
import random

from tqdm import tqdm

## import mydef as my Class correction for projects
import mydef

GA = mydef.GA()

def init():
    line, = ax.plot([], [], color='w', marker='+', markersize=12, lw=3)
    line.set_data([], [])
    
    target_unhit = patches.Rectangle([0, 0], 0, 0, fc='lightgray')
    target_hit = patches.Rectangle([0, 0], 0, 0, fc='crimson')
    
    live.append(line)
    live.append(ax.add_patch(target_unhit))
    live.append(ax.add_patch(target_hit))
    
    return live

def animate(i):

    live[0].set_data(r_allXY[0, i], r_allXY[1, i])

    if r_hit[i]:
        live[1].set_width(0)
        live[1].set_height(0)
        live[1].set_xy([r_ap[0][i], r_ap[1][i]])
        
        live[2].set_width(bx)
        live[2].set_height(bx)
        live[2].set_xy([r_ap[0][i], r_ap[1][i]])
    else:
        live[1].set_width(bx)
        live[1].set_height(bx)
        live[1].set_xy([r_ap[0][i], r_ap[1][i]])
        
        live[2].set_width(0)
        live[2].set_height(0)
        live[2].set_xy([r_ap[0][i], r_ap[1][i]])

    return live

## runs
runs = {'r01':range(300*97)
        , 'r02':range(300*97,300*97*2)
        , 'r03':range(300*97*2,300*97*3)}

for subj in tqdm(GA.list_subj):
    for stage in ['early_practice', 'late_practice']:
        gg = 'GA' if 'early' in stage else ('GB' if 'late' in stage else 'invalid')
        ## load data
        suffix = 'fmri' if 'early' in stage else ('refmri' if 'late' in stage else 'invalid')
        data = scipy.io.loadmat(GA.dir_behav+'/GA%s-%s.mat'%(subj,suffix))

        ## xy
        allXY = data['allXY'][:, :87300]
        
        ## target
        for idx, ID in enumerate(data['targetID'][0]):
            if ID == 0:
                continue
            break
        targetID = np.array(data['targetID'][0,idx:97*3+idx])

        assert targetID[0]==1
        assert targetID[-1]==1
        assert len(targetID)==97*3

        bx = data['boxSize']
        pos = bx*GA.convert_ID(targetID)
        pos.shape

        ## frame
        xFrame, yFrame = np.array([data['xFrame'].squeeze(), data['yFrame'].squeeze()]).astype(int)

        ## hit
        temp = np.zeros(allXY.shape)
        for i in range(300*97*3):
            t = np.floor(i/300).astype(int)
            temp[0][i], temp[1][i] = pos[0][t], pos[1][t]

        err = allXY - temp
        hit = np.zeros(300*97*3)
        for i in range(300*97*3):
            hit[i] = abs(err[0][i]) <= bx*.5 and abs(err[1][i]) <= bx*.5
            
        ## The anchor point (xy)
        temp = np.zeros(pos.shape)
        temp[0], temp[1] = pos[0] - bx*.5, pos[1] - bx*.5

        ap = np.zeros(allXY.shape)
        for i in range(300*97*3):
            t = np.floor(i/300).astype(int)
            ap[0][i], ap[1][i] = temp[0][t], temp[1][t]
            
        ## for 문
        for run, rr in runs.items():
            r_allXY = allXY[:,rr]
            
            r_hit = hit[rr]
            
            r_ap = np.zeros((2,300*97))
            r_ap[0], r_ap[1] = ap[0][rr], ap[1][rr]
            
            ## figure
            ### 1440 * 900
            # ratio = [16, 10]
            ### Square
            ratio = [5, 5]
            scale = 1
            fig = plt.figure(figsize=ratio)
            ax = plt.axes(xlim=np.array([-xFrame, xFrame])*ratio[0]/ratio[1]*scale, ylim=np.array([-yFrame, yFrame])*scale)
            fig.subplots_adjust(left=0, bottom=0, right=1, top=1, wspace=None, hspace=None)

            ### background
            ax.set_facecolor((0., 0., 0.))

            ### grid
            for x in [40, 120, 200]:
                for y in [40, 120, 200]:
                    ax.plot([x,x], [-y,y], color='w', lw=2)
                    ax.plot([-x,-x], [-y,y], color='w', lw=2)
                    ax.plot([-x,x], [y,y], color='w', lw=2)
                    ax.plot([-x,x], [-y,-y], color='w', lw=2)

            live = []

            anim = animation.FuncAnimation(fig, animate, init_func=init
                                           , frames=60*485, interval=16.7
                                           , blit=True)
            anim.save(join(GA.dir_work,'videos','%s.%s%s.%s.mp4'%(GA.today, gg, subj, run))
                      , writer = 'ffmpeg', fps=60)

