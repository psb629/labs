from glob import glob
import sys
import os
# import psutil
from os.path import join, dirname
from os.path import getsize
from os.path import exists
import pickle
import numpy as np
import pandas as pd
import scipy.stats
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.stats.multitest
from statsmodels.sandbox.stats.multicomp import multipletests

# import nilearn.masking
from nilearn import plotting as nplt
from nilearn import image as niimg
import nilearn.decoding

from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.model_selection import cross_validate
from sklearn.model_selection import GroupKFold
from sklearn.preprocessing import StandardScaler
from sklearn.svm import LinearSVC

from datetime import date

class Common:
    #####################
    ## General Modules ##
    #####################
    
    ## date
    today = date.today().strftime("%Y%m%d")
    
    ## ROI images
    roi_imgs = {}
    
    ## fan images
    fan_imgs = {}
    fan_info = None
    
    ## the decoding accuracy
    scores = {}
    
    ## initialize variables
    def initialize(self):
        self.roi_imgs = {}
        self.fan_imgs = {}
        self.fan_info = None
        self.scores = {}
    
    def fast_masking(self, img, roi):
        ## img : data (NIFTI image)
        ## output : (trials, voxels)-dimensional fdata array
        img_data = img.get_fdata()
        roi_mask = roi.get_fdata().astype(bool)
        if img_data.shape[:3] != roi_mask.shape:
            raise ValueError('different shape while masking! img=%s and roi=%s' % (img_data.shape, roi_mask.shape))
        ## the shape is (n_trials, n_voxels) which is to cross-validate for runs. =(n_samples, n_features)
        return img_data[roi_mask, :].T
    
    def save_scores_as_pkl(self, suffix):
        ## scores must exist!
        assert len(self.scores)
        ## store the result came from cross_valid in the script directory
        with open(join(self.dir_script, self.today+'_%s.pkl'%suffix),"wb") as fw:
            pickle.dump(self.scores, fw)
    
    ## show the list of pkl at the location, simultaneously represent overlap
    def show_pkl_list(self, location, word):
        pkl_list = glob('*%s*.pkl'%word)
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
            with open(p,"rb") as fp:
                pkl_n = pickle.load(file=fp)
            for m,q in enumerate(pkl_list[(n+1):]):
                if len(group[m+n+1])!=0:
                    continue
                if getsize(join(location,p))!=getsize(join(location,q)):
                    continue
                ## Comparison sorting
                with open(q,"rb") as fq:
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
    
    def load_scores_from_pkl(self, fname):
        ## scores must be blank!
        assert not len(self.scores)
        ## load scores from the pkl which is in the scripts directory
        with open(join(GA.dir_script, fname), "rb") as fr:
            self.scores = pickle.load(file=fr)
    
    ## draw the figures of ROI images with a standard underlay
    def draw_rois(self, magnitude, n_columns, img_bg):
        ## magnitude: a size of figures
        n_rows = int(np.ceil(len(self.roi_imgs.keys())/n_columns))   # a number of rows
        fig, axes = plt.subplots(n_rows, n_columns, figsize=(n_columns*magnitude, n_rows*magnitude))

        for i, (key, img) in enumerate(self.roi_imgs.items()):
            nvoxels=img.get_fdata().astype(bool).sum()
            print('%s(n_voxels=%d)'%(key,nvoxels))
            if n_rows > 1:
                ax = axes[(i//n_columns),(i%n_columns)]
            else:
                ax = axes[i]
            nplt.plot_roi(roi_img=img, bg_img=img_bg, title='%s(n_voxels=%d)'%(key,nvoxels)
                          , draw_cross=False, black_bg=False
                          , display_mode='ortho', axes=ax)
        return 0

    def draw_lineplot(self, roi_name, title, ylim=[0.225, 0.55], dy=.15, ax=None):
        ## Figure format
        sns.set(style="ticks", context='talk')
        palette = ['#00A8AA','#C5C7D2']
        
        sub_df = self.wit_score[self.wit_score.ROI == roi_name]
        ax = sns.pointplot(x='visit', y='mean_accuracy', hue='mapping', data=sub_df, ax=ax
                           , palette=palette, markers='s', scale=1, ci=68, errwidth=2, capsize=0.1)
        sns.despine()

        ax.set_xlim([-0.4, 1.4])
        ax.set_ylim(ylim)
        ax.set_yticks(np.arange(ylim[0],ylim[1]+.5*dy,dy))
        ax.set_ylabel('Decoding Accuracy')
        ax.axhline(y=0.25, color='k', linestyle='--', alpha=0.25)
    #     ax.get_legend().remove()
        ax.legend(loc='best', frameon=True)
        ax.set_title(title)

        return ax

    def draw_lineplot_with_roi(self, magnitude, roi_name, img_bg, ylim=[0.225, 1.], dy=.5):
        n_columns = 1 # a number of columns
        n_rows = 2    # a number of rows
        fig, axes = plt.subplots(n_rows, n_columns, figsize=(n_columns*magnitude,n_rows*magnitude))
        
        key = roi_name
        img = self.roi_imgs[roi_name]
        print('%s(n_voxles=%d)'%(key,img.get_fdata().sum()))
        self.draw_lineplot(roi_name=key, title=key
                           , ylim=ylim, dy=dy
                           , ax=axes[0])
        nplt.plot_roi(roi_img=img, bg_img=img_bg, title=key
                      , draw_cross=False, black_bg=False
                      , display_mode='ortho', axes=axes[1])
        return 0
    
    def draw_lineplots_with_rois(self, magnitude, n_columns, img_bg, ylim=[0.225, 0.55], dy=.15):
        n_rows = int(2*np.ceil(len(self.roi_imgs.keys())/n_columns))   # a number of rows
        fig, axes = plt.subplots(n_rows, n_columns, figsize=(n_columns*magnitude,n_rows*magnitude))
        
        for i, (key, img) in enumerate(self.roi_imgs.items()):
            print('%s(n_voxles=%d)'%(key,img.get_fdata().sum()))
            self.draw_lineplot(roi_name=key, title=key
                               , ylim=ylim, dy=dy
                               , ax=axes[2*(i//n_columns),(i%n_columns)])
            nplt.plot_roi(roi_img=img, bg_img=img_bg, title=key
                          , draw_cross=False, black_bg=False
                          , display_mode='ortho', axes=axes[2*(i//n_columns)+1,(i%n_columns)])
        return 0

class GA(Common):
    ##################
    ## Initializing ##
    ##################
    
#     def __init__(self):
    
    list_subj = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15'
                 ,'18', '19', '20', '21', '23', '26', '27', '28', '29', '30'
                 ,'31', '32', '33', '34', '35', '36', '37', '38', '42', '44']
    list_stage = ['early_practice', 'early_unpractice', 'late_practice', 'late_unpractice']
    
    ## Locations of directories
    dir_script = '.'
    dir_root = '/Volumes/T7SSD1/GA' # check where the data is downloaded on your disk
    if not exists(dir_root):
        print("You need to connect T7SSD1 with your PC!")
        dir_root = '/Users/clmn/Desktop/GA'
        if exists(dir_root):
            print("dir_root is replaced by %s."%dir_root)
        else:
            print("Error: dir_root doesn't be assigned.")
    dir_fmri = dir_root + '/fMRI_data'
    dir_searchlight = dir_fmri + '/searchlight'
    dir_LSS = dir_fmri + '/preproc_data'
    dir_stats = dir_fmri + '/stats'
    dir_mask = dir_fmri + '/roi'
    dir_dmn = dir_mask + '/DMN'
    dir_loc = dir_mask + '/localizer'
    
    ## the difference in reward rate(=success rate) between GB and GA
    del_RR = np.loadtxt(join(dir_script,"RewardRate_improvement.txt"), delimiter='\n')
    
    ## background image
    img_bg = join(dir_mask,'mni152_2009bet.nii.gz')

    ## labeling with target position
    # 1 - 5 - 25 - 21 - 1 - 25 - 5 - 21 - 25 - 1 - 21 - 5 - 1 - ...
    ##################
    #  1  2  3  4  5 #
    #  6  7  8  9 10 #
    # 11 12 13 14 15 #
    # 16 17 18 19 20 #
    # 21 22 23 24 25 #
    ##################
    target_pos = []
    with open(join(dir_script,'targetID.txt')) as file:
        for line in file:
            target_pos.append(int(line.strip()))
    target_pos = target_pos[1:97]
    # target_path = list(range(1,13))*8
    del(file)
    
    ## LDA analysis
    lda = LinearDiscriminantAnalysis(solver='lsqr', shrinkage='auto')
    
    ## initialize variables
    def initialize(self):
        ## overwrighting
        super().initialize()
        ## additional staements
        self.wit_score = {}
        self.wit_paired_ttest = None
        self.wit_mean_ttest = None
    
    def load_fan(self):
        ## load fan_imgs
        self.fan_imgs={}
        path_list = glob(join(self.dir_mask,'fan280','*.nii.gz'))
        for path in path_list:
            temp = path.split('/')[-1].replace('.nii.gz', '')
            fname = temp.split('.')[-1]
            self.fan_imgs[fname] = nilearn.image.load_img(path)

        self.fan_info = pd.read_csv(join(GA.dir_mask,'fan_cluster_net_20200121.csv'), sep=',', index_col=0)

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
            temp[g+subj, run] = niimg.load_img(join(self.dir_LSS,subj,'betasLSS.%s.%s.nii.gz'%(g+subj,run)))

        ## We suppose to exclude the first slice from the last dimension of this 4D-image
        for key, value in temp.items():
            temp[key] = niimg.index_img(value, np.arange(1, 97))

        ## new arrangement of previous data
        beta = {}
        beta[subj, stage] = niimg.concat_imgs([temp[g+subj, run] for run in list_run])

        return beta

    ## do cross validation with given estimator (default: LDA)
    def cross_valid(self, betas, estimator=lda):
        # output : A leave-one-run-out cross-validation (LORO-CV) result.
        
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

    ## make a wit dataframe
    def make_wit_score(self):
        self.wit_score = pd.DataFrame(columns=['subj','ROI','visit','mapping','accuracy_1','accuracy_2','accuracy_3','mean_accuracy'])

        for keys, values in self.scores.items():
            v, m = keys[1].split('_')
            self.wit_score = self.wit_score.append(
                {'subj': keys[0]
                 ,'ROI': keys[2]
                 ,'visit': v
                 ,'mapping': m
                 ,'accuracy_1': values[0]
                 ,'accuracy_2': values[1]
                 ,'accuracy_3': values[2]
                 ,'mean_accuracy': np.mean(values)}
                , ignore_index=True)
        return self.wit_score

    ## paired t-test
    def do_paired_ttest(self, cond_A, cond_B):
        ## cond_A vs. cond_B :
        ### early_practice vs. late_practice
        ### early_unpractice vs. late_unpractice
        ### early_practice vs. early_unpractice
        ### late_practice vs. late_unpractice
        a1, a2 = cond_A.split('_')
        assert a1 in ['early', 'late']
        assert a2 in ['practice', 'unpractice']
        b1, b2 = cond_B.split('_')
        assert b1 in ['early', 'late']
        assert b2 in ['practice', 'unpractice']

        lines = []
        ROI_list = self.wit_score.ROI.unique()
        for roi in ROI_list:
            A = self.wit_score[(self.wit_score.ROI==roi)&(self.wit_score.visit==a1)&(self.wit_score.mapping==a2)]['mean_accuracy']
            B = self.wit_score[(self.wit_score.ROI==roi)&(self.wit_score.visit==b1)&(self.wit_score.mapping==b2)]['mean_accuracy']
            ttest = scipy.stats.ttest_rel(A, B)
#             reject, pvals_corrected = statsmodels.stats.multitest.fdrcorrection(ttest.pvalue)
            reject, pvals_corrected, _, _ = multipletests(ttest.pvalue, alpha=0.005, method='bonferroni')
            lines.append((roi,cond_A,cond_B,ttest.statistic,ttest.pvalue,reject[0], pvals_corrected[0]))

        self.wit_paired_ttest = pd.DataFrame(lines, columns=['ROI','cond_A','cond_B','t-statistic','Two-sided p-value','rejected','pvalue-corrected'])
        
        return self.wit_paired_ttest

    ## Calculate the T-test for the mean of ONE group of scores.
    def make_wit_mean_ttest(self, stage, mean):
        ## ex) stage == 'early_late', mean == 0.25 (the chance level)
        a1, a2 = stage.split('_')
        assert a1 in ['early', 'late']
        assert a2 in ['practice', 'unpractice']

        lines = []
        ROI_list = self.wit_score.ROI.unique()
        for roi in ROI_list:
            score = self.wit_score[(self.wit_score.ROI==roi)&(self.wit_score.visit==a1)&(self.wit_score.mapping==a2)]['mean_accuracy']
            res_uncorrected = scipy.stats.ttest_1samp(a=score, popmean=mean)
            reject, pvals_corrected, _, _ = multipletests(res_uncorrected.pvalue, alpha=0.005, method='bonferroni')
            lines.append((roi, a1, a2, res_uncorrected.statistic, res_uncorrected.pvalue, reject[0], pvals_corrected[0]))
            
        self.wit_mean_ttest = pd.DataFrame(lines, columns=['ROI', 'visit', 'mapping', 'tval', 'pval_uncorrected', 'reject', 'pval_corrected'])
        return self.wit_mean_ttest