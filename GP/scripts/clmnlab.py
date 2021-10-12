import getpass
import os
from os.path import join, dirname, getsize, exists
from glob import glob
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import itertools
# markers = [next(mks) for i in df["category"].unique()]
# import psutil

import scipy
import statsmodels.stats.multitest
from statsmodels.sandbox.stats.multicomp import multipletests

import sys
import plotly as py
import pickle
import pandas as pd

import nilearn
from nilearn import image, plotting

from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.model_selection import cross_validate
from sklearn.model_selection import GroupKFold
from sklearn.preprocessing import StandardScaler
from sklearn.svm import LinearSVC

from random import random as rand

from datetime import date

from sys import platform

class Common:
    
    def __init__(self):
        
        ## check OS
        self.username = getpass.getuser()
        print("OS :",platform)
        if platform == "linux" or platform == "linux2":
            # linux
            self.dir_gdrive = join('/home',self.username,'GoogleDrive')
        elif platform == "darwin":
            # OS X
            self.dir_gdrive = join('/Users',self.username,'Google Drive','내 드라이브')
#         elif platform == "win32":
#             # Windows...
        
        if exists(self.dir_gdrive):
            print('Google Drive is detected!')
        else:
            print('Google Drive is NOT mounted!')
            del(self.dir_gdrive)
        
        ## Github
        splited = os.getcwd().split('/')
        idx = splited.index('labs')
        self.dir_git = '/'.join(splited[:idx+1])
        if exists(self.dir_git):
            print('Git directory is detected!')
        else:
            print('Git directory is NOT detected!')
            del(self.dir_git)
        del(idx, splited)

        ## date
        self.today = date.today().strftime("%Y%m%d")
    
        ## constant numbers
        self.sig1 = 0.682689492137
        self.sig2 = 0.954499736104
        self.sig3 = 0.997300203937
        
        ## background image
        self.img_bg = join(self.dir_gdrive,'mni152_2009bet.nii.gz')
        
        ## initializing several variables
        self.roi_imgs = {}
        self.fan_imgs = {}
        self.fan_info = pd.read_csv(join(self.dir_gdrive,'Fan280','fan_cluster_net_20200121.csv'), sep=',', index_col=0)

        ## LDA analysis
        self.lda = LinearDiscriminantAnalysis(solver='lsqr', shrinkage='auto')
    
    #######################
    ## several operatros ##
    #######################

    ###############
    ## utilities ##
    ###############
    
    def save_as_pkl(self, path, data, suffix):
        ## scores must exist!
        assert len(data)
        ## save data
        with open(join(path, self.today+'.%s.pkl'%suffix),"wb") as fw:
            pickle.dump(data, fw)
        
    def load_from_pkl(self, fname):
        ## load pkl
        with open(fname, "rb") as fr:
            return pickle.load(file=fr)

    ## show the list of pkl at the location, simultaneously represent overlap
    def show_pkl_list(self, path, word, binary=True):
        if binary:
            read_type = "rb"
        else:
            read_type = "r"
        pkl_list = glob(join(path,'*%s*.pkl'%word))
        df = pd.DataFrame({'name':pkl_list})
        group = ['' for i in pkl_list]
        ## check the identity
        idty = ['a','b','c','d','e','f','g','h','i','j','k','l','m'
                ,'n','o','p','q','r','s','t','u','v','w','x','y','z'
                ,'A','B','C','D','E','F','G','H','I','J','K','L','M'
                ,'N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
        gg = 0
        for n,p in enumerate(pkl_list):
            ## assign a pkl a name of the group
            ## check that the pkl has a group
            if len(group[n])!=0:
                continue
            group[n] = idty[gg]
            ## check the similarity
            with open(p,read_type) as fp:
                pkl_n = pickle.load(file=fp)
            for m,q in enumerate(pkl_list[(n+1):]):
                if len(group[m+n+1])!=0:
                    continue
                if getsize(join(path,p))!=getsize(join(path,q)):
                    continue
                ## Comparison sorting
                with open(q,read_type) as fq:
                    pkl_m = pickle.load(file=fq)
    #             if pkl_n==pkl_m:
    #                 group[m+n] = idty[gg]
                all_same = True
                for key in pkl_n.keys():
                    if not np.array_equal(pkl_n[key], pkl_m[key]):
                        all_same = False
                        break
                if all_same:
                    group[m+n+1] = idty[gg]
            gg += 1
        df['identity']=group
        return df

    ##############
    ## Behavior ##
    ##############
    
    ##########
    ## fMRI ##
    ##########
        
    def fast_masking(self, img, roi):
        ## img : data (NIFTI image)
        ## output : (trials, voxels)-dimensional fdata array
        img_data = img.get_fdata()
        roi_mask = roi.get_fdata().astype(bool)
        if img_data.shape[:3] != roi_mask.shape:
            raise ValueError('different shape while masking! img=%s and roi=%s' % (img_data.shape, roi_mask.shape))
        ## the shape is (n_trials, n_voxels) which is to cross-validate for runs. =(n_samples, n_features)
        return img_data[roi_mask, :].T
    
    def load_1D(self, fname):
        with open(join(fname),'rb') as fr:
            array = np.genfromtxt(fr, delimiter='\n')

        return array

class GA(Common):
    def __init__(self):
        super().__init__()
        
        ## experimental properties
        self.list_subj = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15'
                          ,'18', '19', '20', '21', '23', '26', '27', '28', '29', '30'
                          ,'31', '32', '33', '34', '35', '36', '37', '38', '42', '44']
        self.list_stage = ['early_practice', 'early_unpractice', 'late_practice', 'late_unpractice']
        
        ## define directories
        self.dir_script = '.'
        self.dir_work = join(self.dir_gdrive,'GA')

        self.dir_behav = self.dir_work + '/behav_data'
        self.dir_fmri = self.dir_work + '/fMRI_data'
    
        ## labeling with target position
        # 1 - 5 - 25 - 21 - 1 - 25 - 5 - 21 - 25 - 1 - 21 - 5 - 1 - ...
        ##################
        #  1  2  3  4  5 #
        #  6  7  8  9 10 #
        # 11 12 13 14 15 #
        # 16 17 18 19 20 #
        # 21 22 23 24 25 #
        ##################
        self.target_pos = []
        with open(join(self.dir_script,'targetID.txt')) as file:
            for line in file:
                self.target_pos.append(int(line.strip()))
        self.target_pos = self.target_pos[1:97]
        # self.target_path = list(range(1,13))*8
        del(file, line)
    
    ##############
    ## Behavior ##
    ##############
    
    def convert_ID(self, ID):
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
    
    def calc_mrew(self, behav_datum):
        datum = scipy.io.loadmat(behav_datum)
        nS = int(datum['nSampleTrial'][0][0])
        sec_per_trial = 5  ## time spend(second) in each trial
        ntrial = 12
        nblock = 8
        #ttt = nblock*6 # total number of blocks = 8 blocks/run * 6 runs
        tpr = 97   ## 1 trial/run + 12 trials/block * 8 block/run
        nrun = 7

        temp = datum['LearnTrialStartTime'][0]
        idx_editpoint = [i+1 for i,t in enumerate(temp[:-2]) if (temp[i]>temp[i+1])]

        cnt_hit_all = np.zeros((tpr*nrun,nS), dtype=bool)
        for t,ID in enumerate(datum['targetID'][0][idx_editpoint[0]:]):
            pos = datum['boxSize']*self.convert_ID(ID)
            xy = datum['allXY'][:,nS*t:nS*(t+1)] # allXY.shape = (2, 60 Hz * 5 s/trial * 97 trials/run * 7 runs = 203700 frames)
            err = xy - np.ones((2,nS))*pos.T     # err.shape = (2, nS)
            cnt_hit_all[t,:] = (abs(err[0,:]) <= datum['boxSize']*0.5) & (abs(err[1,:]) <= datum['boxSize']*0.5)

        rew_bin = np.zeros((nrun,sec_per_trial*tpr))
        for r in range(nrun):
            temp = cnt_hit_all[tpr*r:tpr*(r+1),:].reshape(nS*tpr,1)
            for i in range(sec_per_trial*tpr):
                rew_bin[r,i] = sum(temp[60*i:60*(i+1)])

        max_score =  nS*ntrial   ## total frames in a block
        temp = rew_bin[:,sec_per_trial:].reshape(nrun*sec_per_trial*ntrial*nblock)
        norm_mrew = np.zeros(nblock*nrun)
        for i in range(nblock*nrun):
            norm_mrew[i] = sum(temp[sec_per_trial*ntrial*i:sec_per_trial*ntrial*(i+1)])/max_score

        return norm_mrew
    
    ##########
    ## fMRI ##
    ##########
    
