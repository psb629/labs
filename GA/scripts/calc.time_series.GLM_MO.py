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

## 0. ROIs

dir_fmri = '/mnt/sda2/GA/fmri_data/'

roi_paths = {}
roi_regions = {}

## load fan masks

fan_info = pd.read_csv(join('/mnt/sda2/Fan280/fan_cluster_net_20200121.csv'), sep=',', index_col=0)

## - motor system
module = 'somatomotor'

dt = pd.DataFrame()
for network7 in [2]:
    dt = dt.append(fan_info[(fan_info.yeo_7network == network7)])
    
rr = []
for idx in dt.index:
    label = dt.loc[idx,'label']
    
    region = dt.loc[idx,'region']
    rr.append(region)
    
    roi_paths[region] = join(dir_fmri, 'masks/fan280/fan.roi.GA.%03d.nii.gz'%int(label))
    
roi_regions[module] = sorted(rr)

## - visual area
module = 'vision'

dt = pd.DataFrame()
for network7 in [1]:
    dt = dt.append(fan_info[(fan_info.yeo_7network == network7)])
    
rr = []
for idx in dt.index:
    label = dt.loc[idx,'label']
    
    region = dt.loc[idx,'region']
    rr.append(region)
    
    roi_paths[region] = join(dir_fmri, 'masks/fan280/fan.roi.GA.%03d.nii.gz'%int(label))
    
roi_regions[module] = sorted(rr)

## - DMN
 #for module in ['Core', 'MTLsub', 'dMsub']:
 #    rr = []
 #    tmp = glob(join(dir_fmri, 'masks', 'DMN', module+'_*.nii'))
 #    for path in tmp:
 #        region = path.split('/')[-1].replace('.nii', '')
 #        rr.append(region)
 #        roi_paths[region] = path
 #    roi_regions[module] = sorted(rr)
module = 'DMN'

dt = pd.DataFrame()
for network7 in [7]:
    dt = dt.append(fan_info[(fan_info.yeo_7network == network7)])
    
rr = []
for idx in dt.index:
    label = dt.loc[idx,'label']
    
    region = dt.loc[idx,'region']
    rr.append(region)
    
    roi_paths[region] = join(dir_fmri, 'masks/fan280/fan.roi.GA.%03d.nii.gz'%int(label))

roi_regions[module] = sorted(rr)

## check an overlap
atlas = niimg.load_img(roi_paths.values())
print(len(roi_paths.values()), atlas.shape)
tmp = niimg.math_img('np.sum(img, axis=-1, keepdims=True)', img=atlas)

tmp = np.unique(tmp.get_fdata())
print(tmp)
if tmp.shape[0] > 2:
    print('overlapped!')

roi_map_label = []
cnt = 0
for _, nodes in roi_regions.items():
    for node in nodes:
        roi_map_label.append(node)
        path = roi_paths[node]
        if cnt == 0:
            roi_map = niimg.load_img(path)
        else:
            tmp = niimg.load_img(path)
            roi_map = niimg.math_img(img1=roi_map, img2=tmp, formula='img1 + (%d+1)*img2'%cnt)
        cnt+=1
print(roi_map.shape)

print(np.unique(roi_map.get_fdata()))
 #nplt.plot_roi(roi_map, colorbar=True, cmap='Paired')

## 1. Calculating time-series mean activity for each ROI
dir_root = '/home/sungbeenpark/GA'
dir_output = join(dir_root, 'tsmean')
 #stat = 'pb04.errts_tproject'
stat = 'GLM.MO'
res = 'tsmean.%s.7network_1-2-7.pkl'%stat

os.makedirs(dir_output, exist_ok=True)
path_data = glob(join(dir_fmri, 'stats', stat, '??', '????.bp_demean.errts.MO.???.nii.gz'))
masker = NiftiLabelsMasker(labels_img=roi_map
                           , labels=roi_map_label
                           , memory='nilearn_cache', verbose=0)

tsmean = {}
tsmean['map'] = roi_map
tsmean['labels'] = roi_map_label
tsmean['regions'] = roi_regions

for path in tqdm(path_data):
    tmp = path.split('/')[-1].split('.')
    subj = tmp[0]
    run = tmp[-3]
    
    img = niimg.load_img(path)
    tsmean[(subj, run)] = masker.fit_transform(img)

with open(join(dir_output, res), 'wb') as f:
    pickle.dump(tsmean, f)

