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
import statsmodels.stats.multitest

from tqdm import tqdm

# import nilearn.masking
from nilearn import plotting as nplt
from nilearn import image as niimg
import nilearn.decoding

from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.model_selection import cross_validate
from sklearn.model_selection import GroupKFold
from sklearn.preprocessing import StandardScaler
# from sklearn.svm import LinearSVC

from datetime import date
today = date.today().strftime("%Y%m%d")
##==================================================================
dir_script = '.'
dir_root = '/home/sungbeenpark/GA'
dir_data = '/mnt/sda2/GA'

dir_fmri = dir_data + '/fmri_data'
dir_LSS = dir_fmri + '/preproc_data/beta_map'
dir_mask = dir_fmri + '/masks'
dir_loc = dir_mask + '/localizer'

list_subj = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15',
             '18', '19', '20', '21', '23', '26', '27', '28', '29', '30',
             '31', '32', '33', '34', '35', '36', '37', '38', '42', '44']
list_stage = ['early_practice', 'early_unpractice', 'late_practice', 'late_unpractice']
##==================================================================
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

## background image
img_bg = join(dir_mask,'mni152_2009bet.nii.gz')
##==================================================================
def load_beta(subj, run):
    gg, nn = subj[:2], subj[2:]
    ## load betas which were calculated by `3dLSS`
    tmp = niimg.load_img(
        '/mnt/sda2/GA/fmri_data/preproc_data/beta_map/%s/betasLSS.%s.%s.nii.gz'%(nn, subj, run)
    )
    ## We suppose to exclude the first slice from the last dimension of this 4D-image
    beta = niimg.index_img(tmp, range(1,97))
    
    return beta

def concatenate_beta(nn, stage):
    gg = 'GA' if 'early' in stage else('GB' if 'late' in stage else 'invalid')
    mm = 'unprac' if 'unpractice' in stage else('prac' if 'practice' in stage else 'invalid')
    runs = ['r01','r02','r03'] if mm=='prac' else(['r04','r05','r06'] if mm=='unprac' else 'invalid')

    ## load betas
    beta = {}
    for run in runs:
        beta[run] = load_beta(gg+nn, run)

    ## concatenate them
    betas = niimg.concat_imgs([beta[run] for run in runs])

    return betas

def fast_masking(img, roi):
    # img : data (NIFTI image)
    # roi : mask (NIFTI image)
    # output : (trials, voxels)-dimensional fdata array
    img_data = img.get_fdata()
    roi_mask = roi.get_fdata().astype(bool)
    
    if img_data.shape[:3] != roi_mask.shape:
        raise ValueError('different shape while masking! img=%s and roi=%s' % (img_data.shape, roi_mask.shape))
        
    # the shape is (n_trials, n_voxels) which is to cross-validate for runs. =(n_samples, n_features)
    return img_data[roi_mask, :].T

## LDA analysis
lda = LinearDiscriminantAnalysis(solver='lsqr', shrinkage='auto')
def cross_valid(subj, stage, ROI, estimator):
    # output : A leave-one-run-out cross-validation (LORO-CV) result.
    #          Automatically save it as pickle file to root_dir
    ## set the parameters
    nrun = 3
    cv = GroupKFold(nrun)
    y = [j for i in range(nrun) for j in target_pos] ## answer : [5, 25, 21, 1, 25,...]; (288=96*3,)
    group = [i for i in range(nrun) for j in target_pos] ## run number : [0, 0, ..., 1, 1, ..., 2, 2]; (288=96*3,)
    
    ## load beta
    betas = concatenate_beta(nn, stage)
    
    ## cross-validation
    X = fast_masking(img=betas, roi=ROI)
    score = cross_validate(
        estimator=estimator, X=X, y=y, groups=group
        , cv=cv, return_estimator=True, return_train_score=True
    )
    
    return score
##==================================================================
 #module = 'localizer'
 #
 #list_roi = ['n200_c1_L_Postcentral'
 #            , 'n200_c2_R_CerebellumIV-V'
 #            , 'n200_c3_R_Postcentral'
 #            , 'n200_c4_L_Putamen'
 #            , 'n200_c5_R_SMA'
 #            , 'n200_c6_R_CerebellumVIIIb'
 #            , 'n200_c7_L_Thalamus']
 #img_roi = {}
 #for roi in list_roi:
 #    fname = join(dir_loc, '%s_mask.nii'%roi)
 #    img_roi[roi] = nilearn.image.load_img(fname)
##------------------------------------------------------------------
 #module = 'DMN_fan'
 #
 #fan_info = pd.read_csv(join(dir_mask,'fan280','fan_cluster_net_20200121.csv'), sep=',', index_col=0)
 #
 #dt = pd.DataFrame()
 #for network7 in [7]:
 #    dt = dt.append(fan_info[(fan_info.yeo_7network == network7)])
 #
 #img_roi = {}
 #for idx in dt.index:
 #    label = dt.loc[idx,'label']
 #    region = dt.loc[idx,'region']
 #
 #    img_roi[region] = nilearn.image.load_img(
 #            join(dir_fmri, 'masks/fan280/fan.roi.GA.%03d.nii.gz'%int(label))
 #    )
 ### Merge them
 #for ii, img in enumerate(img_roi.values()):
 #    if ii>0:
 #        DMN = nilearn.image.math_img(img1=DMN, img2=img, formula='(img1+img2)>0')
 #    else:
 #        DMN = img
 #
 #module = 'DMN_fan_total'
 #img_roi = {}
 #img_roi['total'] = DMN
##------------------------------------------------------------------
 ### Core
 #amPFC = [(-7,52,-2), (7,52,-2)]
 #PCC = [(-7,-56,25), (7,-56,25)]
 ### DMPFC
 #dmPFC = [(1,52,25)]
 #LTC = [(60,-23,-18), (-60,-23,-18)]
 #TPJ = [(55,-53,27), (-55,-53,27)]
 #temporal_pole = [(-47,13,-37), (47,13,-37)]
 #coords_dmpfc = np.concatenate([dmPFC, LTC, TPJ, temporal_pole])
 #colors_dmpfc = ['lime' for i in coords_dmpfc]
 ### MTL
 #vmPFC = [(1,25,-18)]
 #HF = [(23,-21,-26), (-23,-21,-26)]
 #PHC = [(28,-39,-13), (-28,-39,-13)]
 #Rsp = [(15,-53,9), (-15,-53,9)]
 #pIPL = [(44,-74,33), (-44,-74,33)]
 #coords_mtl = np.concatenate([vmPFC,HF,PHC,Rsp,pIPL])
 #colors_mtl = ['blue' for i in coords_mtl]
 #
 #module = 'DMN_3dUndump'
 #
 #img_roi = {}
 #
 #for pname in sorted(glob(join(dir_mask, 'DMN', '*.nii'))):
 #    region = pname.split('/')[-1].replace('.nii', '')
 #    img_roi[region] = nilearn.image.load_img(pname)
 #
 #del img_roi['Average']
##------------------------------------------------------------------
module = 'vision'

fan_info = pd.read_csv(join(dir_mask,'fan280','fan_cluster_net_20200121.csv'), sep=',', index_col=0)

dt = pd.DataFrame()
for network7 in [1]:
    dt = dt.append(fan_info[(fan_info.yeo_7network == network7)])
            
img_roi = {}
for idx in dt.index:
    label = dt.loc[idx,'label']
    region = dt.loc[idx,'region']
    img_roi[region] = nilearn.image.load_img(
            join(dir_fmri, 'masks/fan280/fan.roi.GA.%03d.nii.gz'%int(label))
            )
## Merge them
for ii, img in enumerate(img_roi.values()):
    if ii>0:
        tmp = nilearn.image.math_img(img1=tmp, img2=img, formula='(img1+img2)>0')
    else:
        tmp = img

module = 'vision_total'
img_roi = {}
img_roi['total'] = tmp
##==================================================================
list_ = []
for region in img_roi.keys():
    for stage in list_stage:
        for subj in list_subj:
            list_.append((region, stage, subj))

df = pd.DataFrame(
    columns=['subj', 'stage', 'ROI', 'acc1', 'acc2', 'acc3', 'mean_acc']
)

for ii, (region, stage, subj) in enumerate(tqdm(list_)):
    score = cross_valid(subj, stage, ROI=img_roi[region], estimator=lda)
    df.loc[ii] = [subj, stage, region, *score['test_score'], np.mean(score['test_score'])]
    
with open(join(dir_root, 'MVPA', 'cross_validate.%s.pkl'%module), 'wb') as f:
    pickle.dump(df, f)
