import getpass
import os
from os.path import join, dirname, getsize, exists
from glob import glob
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
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
        print("OS :",platform)
#         if platform == "linux" or platform == "linux2":
#             # linux
#         elif platform == "darwin":
#             # OS X
#         elif platform == "win32":
#             # Windows...
        
        ## Google Drive
        self.username = getpass.getuser()
        self.dir_root = join('/Users',self.username,'Google Drive','내 드라이브')
        if exists(self.dir_root):
            print('Google Drive is detected!')
        else:
            print('Google Drive is NOT mounted!')
            del(self.dir_root)
        
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
        self.img_bg = join(self.dir_root,'mni152_2009bet.nii.gz')
        
        ## initializing several variables
        self.roi_imgs = {}
        self.fan_imgs = {}
        self.fan_info = pd.read_csv(join(self.dir_root,'Fan280','fan_cluster_net_20200121.csv'), sep=',', index_col=0)
        self.scores = {}
        self.df_score = pd.DataFrame(
            columns=['subj', 'stage', 'ROI','mean_accuracy']
        )
#         self.df_paired_ttest = pd.DataFrame(
#             columns=['ROI','cond_A','cond_B','tval','Two-sided p-value','rejected','pval-corrected']
#         )
#         self.df_1sample_ttest = pd.DataFrame(
#             columns=['ROI', 'stage', 'tval', 'pval_uncorrected', 'rejected', 'pval_corrected']
#         )
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
        with open(join(path, self.today+'_%s.pkl'%suffix),"wb") as fw:
            pickle.dump(data, fw)
        
    def load_from_pkl(self, fname):
        ## load pkl
        with open(join(self.dir_script, fname), "rb") as fr:
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
    
    def plot_rois(self, figsize=(12,12)):
        ## draw the figures of ROI images with a standard underlay
        nrow = 1
        ncol = int(np.ceil(len(self.roi_imgs.keys())/nrow))
        fig, axes = plt.subplots(nrow, ncol, figsize=(ncol*figsize[0], nrow*figsize[1]))
#         axes = np.concatenate(axes)
        sorted_rois = sorted(self.roi_imgs.keys())
        for i, key in enumerate(sorted_rois):
            img = self.roi_imgs[key]
            nvox = img.get_fdata().astype(bool).sum()
            nilearn.plotting.plot_roi(roi_img=img, bg_img=self.img_bg, title='%s(n_voxels=%d)'%(key,nvox)
                                      , draw_cross=False, black_bg=False
                                      , display_mode='ortho', axes=axes[i])
        return 0
    
    def make_df_score(self, fname):
        ## make a dataframe of a decoding accuracy
        ## key: subj, ROI, stage
        ## value: decoding accuracies by runs
        decacc = self.load_from_pkl(fname=fname)
        lines = []
        for keys, values in decacc.items():
            lines.append([keys[0], keys[1], keys[2], np.mean(values)])
        self.df_score = pd.DataFrame(lines, columns=self.df_score.columns)
        return self.df_score

#     def draw_lineplot(self, roi_name, title, ylim=[0.225, 0.55], dy=.15, ax=None):
#         ## Figure format
#         sns.set(style="ticks", context='talk')
#         palette = ['#00A8AA','#C5C7D2']
        
#         sub_df = self.df_score[self.df_score.ROI == roi_name]
#         ax = sns.pointplot(x='visit', y='mean_accuracy', hue='mapping', data=sub_df, ax=ax
#                            , palette=palette, markers='s', scale=1, ci=68, errwidth=2, capsize=0.1)
#         sns.despine()

#         ax.set_xlim([-0.4, 1.4])
#         ax.set_ylim(ylim)
#         ax.set_yticks(np.arange(ylim[0],ylim[1]+.5*dy,dy))
#         ax.set_ylabel('Decoding Accuracy')
#         ax.axhline(y=0.25, color='k', linestyle='--', alpha=0.25)
#     #     ax.get_legend().remove()
#         ax.legend(loc='best', frameon=True)
#         ax.set_title(title)

#         return ax

#     def draw_lineplot_with_roi(self, roi_name, magnitude=8, ylim=[0.225, 1.], dy=.5):
#         n_columns = 1 # a number of columns
#         n_rows = 2    # a number of rows
#         fig, axes = plt.subplots(n_rows, n_columns, figsize=(n_columns*magnitude,n_rows*magnitude))
        
#         key = roi_name
#         img = self.roi_imgs[roi_name]
#         nv = img.get_fdata().sum()
#         print('%s(n_voxles=%d)'%(key, nv))
#         self.draw_lineplot(roi_name=key, title=key
#                            , ylim=ylim, dy=dy
#                            , ax=axes[0])
#         nilearn.plotting.plot_roi(roi_img=img, bg_img=self.img_bg, title='%s (%d)'%(key, nv)
#                                   , draw_cross=False, black_bg=False
#                                   , display_mode='ortho', axes=axes[1])
#         return 0
    
#     def draw_decacc_with_rois(self, magnitude=8, n_columns=1, ylim=[0.225, 0.55], dy=.15):
#         n_rows = int(2*np.ceil(len(self.roi_imgs.keys())/n_columns))   # a number of rows
#         fig, axes = plt.subplots(n_rows, n_columns, figsize=(n_columns*magnitude,n_rows*magnitude))
        
#         for i, (key, img) in enumerate(self.roi_imgs.items()):
#             nvox = img.get_fdata().sum()
#             print('%s(n_voxles=%d)'%(key, nvox))
#             self.draw_lineplot(roi_name=key, title=key
#                                , ylim=ylim, dy=dy
#                                , ax=axes[2*(i//n_columns),(i%n_columns)])
#             nilearn.plotting.plot_roi(roi_img=img, bg_img=self.img_bg, title='%s (%d)'%(key, nvox)
#                                       , draw_cross=False, black_bg=False
#                                       , display_mode='ortho', axes=axes[2*(i//n_columns)+1,(i%n_columns)])
#         return 0

    def plot_score(self, data=None, x=None, y=None, hue=None, ylim=None, hline=None, title=None, ax=None):
        if type(data) != pd.core.frame.DataFrame:
            data = self.df_score
            x = 'stage'
            y = 'mean_accuracy'
            hue = 'ROI'
#         fig = plt.figure(figsize=figsize)
        sns.set(style="ticks", context='talk')
        ax = sns.pointplot(
            data=data
            , x=x, y=y, hue=hue
            , capsize=.1, ci=self.sig1*100, dodge=True
            , ax=ax
        )
        if ylim:
            ax.set_ylim(ylim)
        ax.set_title(title)
        if hline:
            ax.axhline(y=hline, color='k', linestyle='--', alpha=0.25)
        return 0
    
    def do_paired_ttest(self, cond_A, cond_B, alpha=0.005):
        ## paired t-test, cond_A vs. cond_B, or stage_A vs. stage_B

        lines = []
        ROI_list = self.df_score.ROI.unique()
        for roi in ROI_list:
            A = self.df_score[(self.df_score.ROI==roi)&(self.df_score.stage==cond_A)]['mean_accuracy']
            B = self.df_score[(self.df_score.ROI==roi)&(self.df_score.stage==cond_B)]['mean_accuracy']
            ttest = scipy.stats.ttest_rel(A, B)
#             reject, pvals_corrected = statsmodels.stats.multitest.fdrcorrection(ttest.pvalue)
            reject, pvals_corrected, _, _ = multipletests(ttest.pvalue, alpha=alpha, method='bonferroni')
            lines.append((roi,cond_A,cond_B,ttest.statistic,ttest.pvalue,reject[0], pvals_corrected[0]))

        df = pd.DataFrame(lines, columns=['ROI','cond_A','cond_B','tval','Two-sided p-value','rejected','pval-corrected'])
        
        return df

    def do_1sample_ttest(self, stage, mean=None, alpha=0.005):
        ## Calculate the T-test for the mean of ONE group of scores.

        lines = []
        ROI_list = self.df_score.ROI.unique()
        for roi in ROI_list:
            score = self.df_score[(self.df_score.ROI==roi)&(self.df_score.stage==stage)]['mean_accuracy']
            res_uncorrected = scipy.stats.ttest_1samp(a=score, popmean=mean)
            reject, pvals_corrected, _, _ = multipletests(res_uncorrected.pvalue, alpha=alpha, method='bonferroni')
            lines.append((roi, stage, res_uncorrected.statistic, res_uncorrected.pvalue, reject[0], pvals_corrected[0]))
            
        df = pd.DataFrame(lines, columns=['ROI', 'stage', 'tval', 'pval_uncorrected', 'rejected', 'pval_corrected'])
        return df
    
    def merge_fan_rois(self, Yeo_Network=False, Sub_Region=False):
        ## Yeo_Network : an array which has integer elements
        ## Sub_Region : an array which has string elements
        self.load_fan()
        dt = pd.DataFrame()
        if Yeo_Network:
            for nn in Yeo_Network:
                dt = dt.append(self.fan_info[(self.fan_info.yeo_17network == nn)])
        elif Sub_Region:
            for ss in Sub_Region:
                dt = dt.append(self.fan_info[(self.fan_info.subregion_name == ss)])
        temp = {}
        for idx in dt.index:
            nn = dt.loc[idx,'label']
            region = dt.loc[idx,'region']
            temp[region] = self.fan_imgs[str(nn)]
        ## merging
        img0 = nilearn.image.math_img(img1=self.fan_imgs['001'], formula="img1*0")
        for _, img in temp.items():
            img0 = nilearn.image.math_img(img1=img0, img2=img, formula="(img1+img2) > 0")

        return img0

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
        self.dir_work = join(self.dir_root,'GA')

        self.dir_behav = self.dir_work + '/behav_data'
        self.dir_fmri = self.dir_work + '/fMRI_data'
        self.dir_searchlight = self.dir_fmri + '/searchlight'
        self.dir_LSS = self.dir_fmri + '/preproc_data'
        self.dir_stats = self.dir_fmri + '/stats'
        self.dir_mask = self.dir_fmri + '/roi'
        self.dir_dmn = self.dir_mask + '/DMN'
        self.dir_loc = self.dir_mask + '/localizer'
    
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
    
        ## initialize variables
        ## additional staements
        self.df_functional_correl = pd.DataFrame(columns=['subj','visit','mapping','run','roiA','roiB','Pearson_r','pval'])
        #self.rewards = {}
        self.wit_rewards_wide = None
        self.wit_rewards_long = None
        
        ## the difference in reward rate(=success rate) between GB and GA
        self.del_RewardRate = np.loadtxt(join(self.dir_script,"RewardRate_improvement.txt"), delimiter='\n')
    
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
        tpr = 97   ## 1 + 12 trials/block * 8 blocks
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
    
    def make_wit_rewards_wide(self):
        self.wit_rewards_wide = pd.DataFrame(columns=['block%02d'%(block+1) for block in range(48)])
        for subj in self.list_subj:
            for visit in ['early', 'late']:
                suffix = 'fmri' if visit=='early' else('refmri' if visit=='late' else 'invalid')
                subjID = 'GA'+subj if visit=='early' else('GB'+subj if visit=='late' else 'invalid')
                for ii, rew in enumerate(self.calc_mrew(self.dir_behav+'/GA%s-%s.mat'%(subj,suffix))[:48]):
                    self.wit_rewards_wide.loc[subjID,'block%02d'%(ii+1)] = rew
        for col in self.wit_rewards_wide.columns:
            self.wit_rewards_wide[col] = self.wit_rewards_wide[col].astype(float)
                    
        return self.wit_rewards_wide
    
    def make_wit_rewards_long(self):
        self.wit_rewards_long = pd.DataFrame(columns=['subj','visit','block','reward'])
        row = 0
        for subj in self.list_subj:
            for visit in ['early', 'late']:
                suffix = 'fmri' if visit=='early' else('refmri' if visit=='late' else 'invalid')
                rewards = self.calc_mrew(self.dir_behav+'/GA%s-%s.mat'%(subj,suffix))[:48]
                for block, rew in enumerate(rewards):
                    self.wit_rewards_long.loc[row,'subj'] = subj
                    self.wit_rewards_long.loc[row,'visit'] = visit
                    self.wit_rewards_long.loc[row,'block'] = block+1
                    self.wit_rewards_long.loc[row,'reward'] = rew
                    row += 1
        self.wit_rewards_long.block = self.wit_rewards_long.block.astype(int)
        self.wit_rewards_long.reward = self.wit_rewards_long.reward.astype(float)
        
        return self.wit_rewards_long
    
#     def get_mean_rewards(self):
#         self.rewards = {}
#         for nn in self.list_subj:
#             self.rewards['GA'+nn] = self.calc_mrew(self.dir_behav + '/GA%s-fmri.mat'%(nn))
#             self.rewards['GB'+nn] = self.calc_mrew(self.dir_behav + '/GA%s-refmri.mat'%(nn))
#             print(nn, end='\r')
#         return 0
    
    ##########
    ## fMRI ##
    ##########
    
    def load_fan(self):
        ## load fan_imgs
        self.fan_imgs={}
        path_list = glob(join(self.dir_mask,'fan280','*.nii.gz'))
        for path in path_list:
            temp = path.split('/')[-1].replace('.nii.gz', '')
            fname = temp.split('.')[-1]
            self.fan_imgs[fname] = nilearn.image.load_img(path)

    def load_beta(self, subj, stage):

        assert subj in self.list_subj
        print(subj, stage, end='\r')
        ## betasLSS.G???.r0?.nii.gz
        a, b = stage.split('_')
        assert ((a == 'early')|(a == 'late'))
        assert ((b == 'practice')|(b == 'unpractice'))
        g = 'GA' if a == 'early' else 'GB'
        list_run = ['r01', 'r02', 'r03'] if b == 'practice' else ['r04', 'r05', 'r06']

        ## load betas
        temp = {}
        for run in list_run:
            temp[g+subj, run] = nilearn.image.load_img(join(self.dir_LSS,subj,'betasLSS.%s.%s.nii.gz'%(g+subj,run)))

        ## We suppose to exclude the first slice from the last dimension of this 4D-image
        for key, value in temp.items():
            temp[key] = nilearn.image.index_img(value, np.arange(1, 97))

        ## new arrangement of previous data
        beta = {}
        beta[subj, stage] = nilearn.image.concat_imgs([temp[g+subj, run] for run in list_run])

        return beta

    def cross_valid(self, betas, estimator=None):
        # output : A leave-one-run-out cross-validation (LORO-CV) result.
        
        ## do cross validation with given estimator (default: LDA)
        if not estimator:
            estimator = self.lda
        ## set the parameters
        nrun = 3
        cv = GroupKFold(nrun)
        y = [j for i in range(nrun) for j in self.target_pos] ## answer : [5, 25, 21, 1, 25,...]
        group = [i for i in range(nrun) for j in self.target_pos] ## run number : [0, 0, ..., 1, 1, ..., 2, 2]
        ## cross-validation
        for subj, stage in betas.keys():
            for region, img in self.roi_imgs.items():
                print(subj, stage, region, end='\r')
                X = self.fast_masking(img=betas[subj, stage], roi=img)
                score = cross_validate(estimator=estimator, X=X, y=y, groups=group
                                       , cv=cv, return_estimator=True, return_train_score=True)
                self.scores[subj, stage, region] = score['test_score']
        return self.scores
    
    def plot_decacc(self, figsize=(12,12), ylim=None, hline=None):
        ## create new columns to use as 'x' and 'hue'
        visit = []
        mapping = []
        for s in self.df_score.stage:
            [v, m] = s.split('_')
            visit.append(v)
            mapping.append(m)
        temp = self.df_score; temp['visit'] = visit; temp['mapping'] = mapping
        
        ## plot
        nroi = len(temp.ROI.unique())
        nrow = 1
        ncol = nroi
        fig, axes = plt.subplots(nrows=nrow, ncols=ncol, figsize=(figsize[0]*ncol,figsize[1]*nrow))
        for i, roi in enumerate(sorted(temp.ROI.unique())):
            self.plot_score(
                data=temp[temp.ROI==roi]
                , x='visit', y='mean_accuracy', hue='mapping'
                , title=roi, ax=axes[i]
                , ylim=ylim, hline=hline
            )
        return 0
    
#     def make_wit_functional_correl(self, roi_imgs):
#         runs = ['r01','r02','r03','r04','r05','r06']
#         sorted_rois = sorted(roi_imgs.keys())
#         lines = []
#         for subj in self.list_subj:
#             for visit in ['early','late']:
#                 gg = 'GA' if visit=='early' else ('GB' if visit=='late' else 'invalid')
#                 for run in runs:
#                     print(subj, visit, run, end='\t\t\t\r')
#                     mapping = 'practice' if run in ['r01','r02','r03'] else('unpractice' if run in ['r04','r05','r06'] else 'invalid')
#                     ## load errts
#                     errts = nilearn.image.load_img(join(self.dir_stats,'GLM.MO.RO',subj,'%s.bp_demean.errts.MO.RO.%s.nii.gz'%(gg+subj,run)))
#                     assert errts.shape[-1]==1096
#                     ## mean values in each ROI
#                     Xmeans = {}
#                     for region in sorted_rois:
# #                         print(subj, visit, run, ": masking... ", end='\r')
#                         ## masking
#                         X = self.fast_masking(img=errts, roi=roi_imgs[region])
#                         ## calculate a voxel-wise mean of betas by each region
#                         Xmeans[region] = np.mean(X, axis=1)
#                     ## obatin Pearson correlation coefficients
#                     for i, roiA in enumerate(sorted_rois[:-1]):
#                         for roiB in sorted_rois[i+1:]:
#                             r, p = scipy.stats.pearsonr(x=Xmeans[roiA], y=Xmeans[roiB])
#                             lines.append([subj, visit, mapping, run, roiA, roiB, r, p])
#         self.wit_functional_correl = pd.DataFrame(
#             data=lines, columns=['subj','visit','mapping','run','roiA','roiB','Pearson_r','pval']
#         )
#         return self.wit_functional_correl

    def load_tsmean(self, subj, visit, run, ROI):
        if ROI in list(self.fan_info.region):
            mask = 'fan%s'%(list(self.fan_info[self.fan_info.region==ROI].label)[0])
        else:
            mask = ROI
        
        gg = 'GA' if visit=='early' else ('GB' if visit=='late' else None)
        ## my result
        with open(join(self.dir_stats,'GLM.MO','tsmean',mask,'tsmean.bp_demean.errts.MO.%s.%s.%s.1D'%(gg+subj,run,mask)),'r') as fr:
            tsmean = np.genfromtxt(fr, delimiter='\n')
        return tsmean
    
    def make_df_functional_correl_from_tsmean(self, subj, visit, mapping, rois):
        ## Loading mean time series data on ROI from pre-created 1D files.
        sorted_rois = sorted(rois)
        lines = []
        
        runs = ['r01','r02','r03'] if mapping=='practice' else (['r04','r05','r06'] if mapping=='unpractice' else 'invalid')
        for run in runs:
            print(subj, visit, run, end='\t\t\t\r')
            for roiA in sorted_rois:
                tsmean_A = self.load_tsmean(subj, visit, run, roiA)
                for roiB in sorted_rois:
                    tsmean_B = self.load_tsmean(subj, visit, run, roiB)
                    r, p = scipy.stats.pearsonr(x=tsmean_A, y=tsmean_B)
                    lines.append([subj, visit, mapping, run, roiA, roiB, r, p])
                    self.df_functional_correl = pd.DataFrame(lines, columns=['subj','visit','mapping','run','roiA','roiB','Pearson_r','pval'])
        return self.df_functional_correl
    
    def make_df_functional_correl_from_errts(self, subj, visit, mapping, fdir, fname, rois):
        ## Etracting time series from errts data
        sorted_rois = sorted(rois.keys())
        lines = []

        runs = ['r01','r02','r03'] if mapping=='practice' else (['r04','r05','r06'] if mapping=='unpractice' else 'invalid')
        gg = 'GA' if visit=='early' else ('GB' if visit=='late' else 'invalid')
        for run in runs:
            print(subj, visit, run, end='\t\t\t\r')
            ## load errts
            errts = nilearn.image.load_img(join(self.dir_stats,fdir,subj,'%s.%s.%s.nii.gz'%(gg+subj,fname,run)))
            assert errts.shape[-1]==1096
            ## mean values in each ROI
            Xmeans = {}
            for region in sorted_rois:
                ## masking
                X = self.fast_masking(img=errts, roi=rois[region])
                ## calculate a voxel-wise mean of betas by each region
                Xmeans[region] = np.mean(X, axis=1)
            ## obatin Pearson correlation coefficients
            for i, roiA in enumerate(sorted_rois[:-1]):
                for roiB in sorted_rois[i+1:]:
                    r, p = scipy.stats.pearsonr(x=Xmeans[roiA], y=Xmeans[roiB])
                    lines.append([subj, visit, mapping, run, roiA, roiB, r, p])
        self.df_functional_correl = pd.DataFrame(
            data=lines, columns=['subj','visit','mapping','run','roiA','roiB','Pearson_r','pval']
        )
        return self.df_functional_correl

#     def load_tsmean_from_YY(self, gg):
#         ## tsmean -> (30 people, 6 runs, 1096 times, 46 ROIs): a mean value of BOLDs
#         gg = 'GA' if visit=='early' else ('GB' if visit=='late' else None)
#         data_dir = join(self.dir_work,'NAS05_data','fmri_data','glm_results','MO_errts','network_analysis')
#         if gg == 'GA':
#             with open(join(data_dir,"GA_MO_errts_timeseriesmean.pkl"), "rb") as file:
#                 tsmean = pickle.load(file)   ## (subj, run, time, ROI): a mean value of BOLDs
#         elif gg == 'GB':
#             with open(join(data_dir,"NAS05_data","network_analysis","GB_MO_errts_timeseriesmean.pkl"), "rb") as file:
#                 tsmean = pickle.load(file)   ## (subj, run, time, ROI): a mean value of BOLDs
#         return tsmean