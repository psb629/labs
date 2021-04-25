from glob import glob
import sys
import os
# import psutil
from os.path import join, dirname
from os.path import getsize
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

class GA:
#     def __init__(self):
    ## 
    list_subj = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15'
                 ,'18', '19', '20', '21', '23', '26', '27', '28', '29', '30'
                 ,'31', '32', '33', '34', '35', '36', '37', '38', '42', '44']
    list_stage = ['early_practice', 'early_unpractice', 'late_practice', 'late_unpractice']

    ## Locations of directories
    dir_script = '.'
    dir_root = '/Volumes/T7SSD1/GA' # check where the data is downloaded on your disk
    dir_fmri = dir_root + '/fMRI_data'
    dir_LSS = dir_fmri + '/preproc_data'
    dir_stats = dir_fmri + '/stats'
    dir_mask = dir_fmri + '/roi'
    dir_dmn = dir_mask + '/DMN'
    dir_loc = dir_mask + '/localizer'

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
    
    ## LDA analysis
    lda = LinearDiscriminantAnalysis(solver='lsqr', shrinkage='auto')
    
    ## Initializing
    scores = {}
    pvals = {}

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
    
    def fast_masking(self, img, roi):
        # img : data (NIFTI image)
        # roi : mask (NIFTI image)
        # output : (trials, voxels)-dimensional fdata array
        img_data = img.get_fdata()
        roi_mask = roi.get_fdata().astype(bool)

        if img_data.shape[:3] != roi_mask.shape:
            raise ValueError('different shape while masking! img=%s and roi=%s' % (img_data.shape, roi_mask.shape))

        # the shape is (n_trials, n_voxels) which is to cross-validate for runs. =(n_samples, n_features)
        return img_data[roi_mask, :].T

    ## do cross validation with given estimator (default: LDA)
    def cross_valid(self, betas, ROI_imgs, estimator=lda):
        # output : A leave-one-run-out cross-validation (LORO-CV) result.
        #          Automatically save it as pickle file to root_dir
        ## set the parameters
        nrun = 3
        cv = GroupKFold(nrun)
        y = [j for i in range(nrun) for j in self.target_pos] ## answer : [5, 25, 21, 1, 25,...]
        group = [i for i in range(nrun) for j in self.target_pos] ## run number : [0, 0, ..., 1, 1, ..., 2, 2]

        ## cross-validation
        for subj, stage in betas.keys():
            for name, img in ROI_imgs.items():
                print(subj, stage, name, end='\r')
                X = self.fast_masking(img=betas[subj, stage], roi=img)
                score = cross_validate(estimator=estimator, X=X, y=y, groups=group
                                       , cv=cv, return_estimator=True, return_train_score=True)
                self.scores[subj, stage, name] = score['test_score']
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
    def do_paired_t_test(self, cond_A, cond_B):
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

        ROI_list = self.wit_score.ROI.unique()
        for roi in ROI_list:
            A = self.wit_score[(self.wit_score.ROI==roi)&(self.wit_score.visit==a1)&(self.wit_score.mapping==a2)]['mean_accuracy']
            B = self.wit_score[(self.wit_score.ROI==roi)&(self.wit_score.visit==b1)&(self.wit_score.mapping==b2)]['mean_accuracy']
            ttest = scipy.stats.ttest_rel(A, B)
            self.pvals[roi,cond_A+'/'+cond_B] = statsmodels.stats.multitest.fdrcorrection(ttest.pvalue)

        return self.pvals

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
            res_corrected = multipletests(res_uncorrected.pvalue, alpha=0.005, method='bonferroni')
            reject, pvals_corrected, _, _ = res_corrected
            lines.append((roi, a1, a2, res_uncorrected.statistic, res_uncorrected.pvalue, reject[0], pvals_corrected[0]))
            
        self.wit_mean_ttest = pd.DataFrame(lines, columns=['ROI', 'visit', 'mapping', 'tval', 'pval_uncorrected', 'reject', 'pval_corrected'])
        return self.wit_mean_ttest

    ## Figure format
    sns.set(style="ticks", context='talk')
    palette = ['#00A8AA','#C5C7D2']

    def draw_lineplot(self, roi_name, title, ax=None):

        sub_df = self.wit_score[self.wit_score.ROI == roi_name]
        ax = sns.pointplot(x='visit', y='mean_accuracy', hue='mapping', data=sub_df, ax=ax
                           , palette=self.palette, markers='s', scale=1, ci=68, errwidth=2, capsize=0.1)
        sns.despine()

        ax.set_xlim((-0.4, 1.4))
        ax.set_ylim(0.225, 0.55)
        ax.set_yticks(np.arange(.25,.90,.15))
        ax.set_ylabel('Decoding Accuracy')
        ax.axhline(y=0.25, color='k', linestyle='--', alpha=0.25)
    #     ax.get_legend().remove()
        ax.legend(loc='best', frameon=True)
        ax.set_title(title)

        return ax