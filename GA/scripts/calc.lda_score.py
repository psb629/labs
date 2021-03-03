# ================================================================
# Foundation
## Modules
from glob import glob
import sys
import os
# import psutil
from os.path import join, dirname
import pickle
import numpy as np
# import pandas as pd
import scipy.stats
import statsmodels.stats.multitest

# import nilearn.masking
# from nilearn import plotting as nplt
from nilearn import image as niimg
import nilearn.decoding

from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.model_selection import cross_validate
from sklearn.model_selection import GroupKFold
# from sklearn.svm import LinearSVC

from datetime import date
today = date.today().strftime("%Y%m%d")
# ================================================================
# def _check():
#     pid = os.getpid()
#     py = psutil.Process(pid)
#     cpu_usage = os.popen("ps aux | grep %s | grep -v grep | awk '{print $3}'"%str(pid)).read()[:-1] # %CPU
# #     memory_usage = py.memory_info().rss # in bytes
#     memory_usage = os.popen("ps aux | grep %s | grep -v grep | awk '{print $4}'"%str(pid)).read()[:-1] # %MEM
#     return pid, cpu_usage, memory_usage
# ================================================================
## create variables that point to the location of the configuration
root_dir = '/Volumes/T7SSD1/GA' # check where the data is downloaded on your disk
script_dir = '.'
fmri_dir = join(root_dir,'fMRI_data')
LSS_dir = join(fmri_dir,'preproc_data')
mask_dir = join(fmri_dir,'roi')
loc_dir = join(mask_dir,'localizer')

subj_list = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15',
             '18', '19', '20', '21', '23', '26', '27', '28', '29', '30',
             '31', '32', '33', '34', '35', '36', '37', '38', '42', '44']
stage_list = ['early_practice', 'early_unpractice', 'late_practice', 'late_unpractice']
# ================================================================
def load_betas(subj, stage):
    assert subj in subj_list
    print(subj, stage)
    
    ## betasLSS.G???.r0?.nii.gz
    a, b = stage.split('_')
    assert ((a == 'early')|(a == 'late'))
    assert ((b == 'practice')|(b == 'unpractice'))
    g = 'GA' if a == 'early' else 'GB'
    run_list = ['r01', 'r02', 'r03'] if b == 'practice' else ['r04', 'r05', 'r06']
    
    ## load betas
    temp = {}
    for run in run_list:
        temp[g+subj, run] = niimg.load_img(join(LSS_dir,subj,'betasLSS.%s.%s.nii.gz'%(g+subj,run)))

    ## We suppose to exclude the first slice from the last dimension of this 4D-image
    for key, value in temp.items():
        temp[key] = niimg.index_img(value, np.arange(1, 97))

    ## new arrangement of previous data
    beta = {}
    beta[subj, stage] = niimg.concat_imgs([temp[g+subj, run] for run in run_list])
        
    return beta
# ================================================================
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
with open(join(root_dir,'targetID.txt')) as file:
    for line in file:
        target_pos.append(int(line.strip()))
target_pos = target_pos[1:97]
# target_path = list(range(1,13))*8
# ================================================================
betas = {}
for subj in subj_list:
    for stage in stage_list:
        beta = load_betas(subj, stage)
        betas[subj, stage] = beta[subj, stage]
# ================================================================
# Ventral visual stream
roi_imgs = {}
## ROIs
path_list = glob(join(mask_dir, 'TT_Daemon', '*.brik1.BA???.*.nii.gz'))
for path in path_list:
    temp = path.split('/')[-1].replace('.nii', '')
    fname = temp.split('.')[2]
    roi_imgs[fname] = nilearn.image.load_img(path)
# ================================================================
## Cross-Validation
def fast_masking(img, roi):
    # img : data (NIFTI image)
    # roi : mask (NIFTI image)
    # output : (trials, voxels)-dimensional fdata array
    img_data = img.get_fdata()
    roi_mask = roi.get_fdata().astype(bool)
    
    if img_data.shape[:3] != roi_mask.shape:
        raise ValueError('different shape while masking! img=%s and roi=%s' % (img_data.shape, roi_mask.shape))

    return img_data[roi_mask, :].T    # the shape is (trials, voxels) which is to cross-validate for runs
# ================================================================
## LDA analysis
estimator = LinearDiscriminantAnalysis(solver='lsqr', shrinkage='auto')
# ================================================================
def cross_valid(betas, ROI_imgs, estimator):
    # output : A leave-one-run-out cross-validation (LORO-CV) result.
    #          Automatically save it as pickle file to root_dir
    ## set the parameters
    nrun = 3
    cv = GroupKFold(nrun)
    y = [j for i in range(nrun) for j in target_pos] ## answer : [5, 25, 21, 1, 25,...]
    group = [i for i in range(nrun) for j in target_pos] ## run number : [0, 0, ..., 1, 1, ..., 2, 2]
    
    ## cross-validation
    scores = {}
    for subj, stage in betas.keys():
        for name, img in ROI_imgs.items():
            print(subj, stage, name, end='\r')
            X = fast_masking(img=betas[subj, stage], roi=img)
            score = cross_validate(estimator=estimator, X=X, y=y, groups=group
                                   , cv=cv, return_estimator=True, return_train_score=True)
            scores[subj, stage, name] = score['test_score']
    return scores
# ================================================================
scores = cross_valid(betas, roi_imgs, estimator)
# ================================================================
output_dir = script_dir
pickle_name = 'visual_stream'
with open(join(output_dir, today+'_%s.pkl'%pickle_name),"wb") as fw:
    pickle.dump(scores, fw)
# ================================================================
