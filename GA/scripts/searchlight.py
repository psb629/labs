#!/usr/bin/env python

from glob import glob
import sys
import os
from os.path import join, dirname, exists
from os.path import getsize

import pickle
import numpy as np
import scipy.stats

from tqdm import tqdm

from nilearn import plotting as nplt
from nilearn import image as niimg
import nilearn.decoding

from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.model_selection import GroupKFold

## =================================================================
dir_script = '/home/sungbeenpark/Github/labs/GA/scripts'
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

## =================================================================
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

## group full mask
full_mask = nilearn.image.load_img('/mnt/sda2/GA/fmri_data/masks/full_mask.GAGB.nii.gz')
## gray matter
GM = nilearn.image.load_img("/home/sungbeenpark/GA/searchlight/mask.fan280xGAGB.nii")
## =================================================================
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

def run_searchlight(subj, stage, radius, mask):

    nrun = 3
    cv = GroupKFold(nrun)
    X = concatenate_beta(subj, stage)
    y = [j for i in range(nrun) for j in target_pos] # answer
    group = [i for i in range(nrun) for j in target_pos] # run number
 #   estimator = LinearSVC(max_iter=1000)
    estimator = LinearDiscriminantAnalysis(solver='lsqr', shrinkage='auto')
    radius = radius
    chance_level = 0.25

    SearchLight = nilearn.decoding.SearchLight(
        mask_img=mask
        , radius=radius
        , estimator=estimator
 #       , n_jobs=4
        , verbose=False
        , cv=cv
        , scoring='balanced_accuracy'
    )

    SearchLight.fit(X, y, group)
    score = SearchLight.scores_ - chance_level

    return nilearn.image.new_img_like(full_mask, score)
## =================================================================
list_ = []
for stage in ['early_practice', 'late_practice']:
    for subj in list_subj:
        list_.append((stage, subj))

radius = 6
for (stage, subj) in tqdm(list_):
    path = '/home/sungbeenpark/GA/searchlight/gray_matter/searchlight.%s.%s.%s.r=%d.nii'%(subj,stage,'lda',radius)
    if exists(path):
        continue
    img = run_searchlight(subj, stage, radius=radius, mask=GM)
    img.to_filename(path)
