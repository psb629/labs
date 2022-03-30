#!/usr/bin/env python

from glob import glob
import sys
import getpass
import os
# import psutil
from os.path import join, exists
from os.path import getsize
import pickle
import numpy as np
import pandas as pd
import scipy

from tqdm import tqdm

import seaborn as sns
import statsmodels.stats.multitest
# from statsmodels.sandbox.stats.multicomp import multipletests
# import nilearn.masking
from nilearn import plotting as nplt
from nilearn import image as niimg
from nilearn.input_data import NiftiLabelsMasker
# from nilearn.regions import connected_label_regions
from nilearn.connectome import ConnectivityMeasure
import nilearn.decoding

from sklearn.discriminant_analysis import LinearDiscriminantAnalysis
from sklearn.model_selection import cross_validate
from sklearn.model_selection import GroupKFold
from sklearn.preprocessing import StandardScaler
# from sklearn.svm import LinearSVC

## experimental properties
list_subj = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15'
             ,'18', '19', '20', '21', '23', '26', '27', '28', '29', '30'
             ,'31', '32', '33', '34', '35', '36', '37', '38', '42', '44']
list_stage = ['early_practice', 'early_unpractice', 'late_practice', 'late_unpractice']

## define directories
dir_fmri = '/mnt/sda2/GA/fmri_data/'
dir_root = '/home/sungbeenpark/GA'
dir_output = join(dir_root, 'AAL')
os.makedirs(dir_output, exist_ok=True)

## load atlas
from nilearn import datasets

atlas_AAL = nilearn.datasets.fetch_atlas_aal(version='SPM12')

atlas = niimg.load_img(atlas_AAL.maps)
labels = atlas_AAL.labels

## save these
atlas.to_filename(join(dir_output,'atlas_AAL.nii'))
np.savetxt(join(dir_output,'labels_AAL.txt'), labels, fmt='%s', newline='\n')

masker = NiftiLabelsMasker(
    labels_img=atlas
    , labels=labels
    , mask_img=join(dir_fmri, 'masks', 'full_mask.GAGB.nii.gz')
    , memory='/home/sungbeenpark/nilearn_data/nilearn_cache', verbose=0
)

## Calculating time-series mean activity for each ROI
stat = 'pb04.errts_tproject'
fin = 'time_series.%s.AAL.pkl'%stat

path_data = glob(join(dir_fmri, stat, '??', '*.nii'))

time_series = {}

for path in tqdm(path_data):
    tmp = path.split('.')
    subj = tmp[-3]
    run = tmp[-2]
    
    img = niimg.load_img(path)
    time_series[(subj, run)] = masker.fit_transform(img)

with open(join(dir_output, fin), 'wb') as f:
    pickle.dump(time_series, f)
