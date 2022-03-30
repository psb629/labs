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

## load ROIs

fan_info = pd.read_csv(join('/mnt/sda2/Fan280/fan_cluster_net_20200121.csv'), sep=',', index_col=0)
dir_data = '/mnt/sda2/GA/fmri_data/'

roi_paths = {}
roi_regions = {}

dt = pd.DataFrame()
for network7 in range(9):
    dt = dt.append(fan_info[(fan_info.yeo_7network == network7)])
            
for idx in dt.index:
    region = dt.loc[idx,'full_name']
    #region = 'fan%03d'%dt.loc[idx,'label']

    network = dt.loc[idx,'yeo_network_name']
    if not network in roi_regions.keys():
        roi_regions[network] = []
    roi_regions[network].append(region)
                                                        
    label = dt.loc[idx,'label']
    roi_paths[region] = join(dir_data, 'masks/fan280/fan.roi.GA.%03d.nii.gz'%int(label))

## check an overlap
atlas = niimg.load_img(roi_paths.values())
print(len(roi_paths.values()), atlas.shape)
tmp = niimg.math_img('np.sum(img, axis=-1, keepdims=True)', img=atlas)

tmp = np.unique(tmp.get_fdata())
print(tmp)
if tmp.shape[0] > 2:
    print('overlapped!')
    raise

roi_map_label = []
cnt = 0
for nodes in roi_regions.values():
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

## Calculating time-series mean activity for each ROI
dir_root = '/home/sungbeenpark/GA'
dir_res = join(dir_root, 'tsmean')
stat = 'pb04.errts_tproject'
res = 'tsmean.%s.274_fans.pkl'%stat

os.makedirs(dir_res, exist_ok=True)

path_data = glob(join(dir_data, stat, '??', '*.nii'))

masker = NiftiLabelsMasker(labels_img=roi_map
                           , labels=roi_map_label
                           , memory='nilearn_cache', verbose=0)

tsmean = {}
tsmean['map'] = roi_map
tsmean['labels'] = roi_map_label
tsmean['regions'] = roi_regions

for path in tqdm(path_data):
    tmp = path.split('.')
    subj = tmp[-3]
    run = tmp[-2]
    
    img = niimg.load_img(path)
    tsmean[(subj, run)] = masker.fit_transform(img)

with open(join(dir_res, res), 'wb') as f:
    pickle.dump(tsmean, f)

