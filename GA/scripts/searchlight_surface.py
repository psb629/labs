#!/usr/bin/env python

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
import statannot
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
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

from nilearn import datasets, surface
from sklearn import neighbors
from sklearn.model_selection import KFold
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import RidgeClassifier
from nilearn.decoding.searchlight import search_light
## ========================================================
dir_script = '/home/sungbeenpark/Github/labs/GA/scripts'
dir_root = '/home/sungbeenpark/GA'
dir_data = '/mnt/sda2/GA'

dir_fmri = dir_data + '/fmri_data'
dir_LSS = dir_fmri + '/beta_map'
dir_mask = dir_fmri + '/masks'
dir_fig = dir_root

list_subj = ['01', '02', '05', '07', '08', '11', '12', '13', '14', '15',
             '18', '19', '20', '21', '23', '26', '27', '28', '29', '30',
             '31', '32', '33', '34', '35', '36', '37', '38', '42', '44']
list_stage = ['early_practice', 'early_unpractice', 'late_practice', 'late_unpractice']
## ========================================================
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
y = np.concatenate([target_pos for ii in range(3)])

idx = np.concatenate([np.arange(96)+1, np.arange(96)+1+97, np.arange(96)+1+97*2])
## ========================================================
## For this we need to get a mesh representing the geometry of the surface.
## We could use an individual mesh, but we first resort to a standard mesh,
## the so-called fsaverage5 template from the FreeSurfer software.
fsaverage = datasets.fetch_surf_fsaverage(mesh='fsaverage5') # (10242 nodes)
hemi = 'left'
pial_mesh = fsaverage['pial_' + hemi] # Gifti file, right hemisphere pial surface mesh

# To define the :term:`BOLD` responses to be included within each searchlight "sphere"
# we define an adjacency matrix based on the inflated surface vertices such
# that nearby surfaces are concatenated within the same searchlight.
infl_mesh = fsaverage['infl_' + hemi] # Gifti file, right hemisphere inflated pial
coords, _ = surface.load_surf_mesh(infl_mesh)
nn = neighbors.NearestNeighbors(radius=3.)
adjacency = nn.fit(coords).radius_neighbors_graph(coords).tolil()

# Simple linear estimator preceded by a normalization step
# estimator = make_pipeline(
#     StandardScaler()
#     , RidgeClassifier(alpha=10.)
# )
estimator = LinearDiscriminantAnalysis(solver='lsqr', shrinkage='auto')

# Define cross-validation scheme
cv = KFold(n_splits=3, shuffle=False)

# chance level
chance = .25
## ========================================================
list_ = []
for stage in list_stage:
    for nn in list_subj:
        list_.append((stage, nn))
Scores = {}

for stage, nn in tqdm(list_):
    gg = 'GA' if 'early' in stage else ('GB' if 'late' in stage else 'invalid')
    runs = ['r04','r05','r06'] if 'unprac' in stage else (['r01','r02','r03'] if 'prac' in stage else 'invalid')

    tmp = niimg.concat_imgs(
        [join(dir_LSS,nn,'betasLSS.%s.%s.nii.gz'%(gg+nn, run)) for run in runs]
    )
    beta_map = niimg.index_img(tmp, idx)

    ## The projection function simply takes the fMRI data and the mesh.
    ## Note that those correspond spatially, are they are both in MNI space.
    ## (Average voxels 5 mm close to the 3d pial surface)

    X = surface.vol_to_surf(beta_map, pial_mesh, radius=5.).T

    # Cross-validated search light
    Scores[(nn, stage)] = search_light(
        X, y
        , estimator, adjacency
        , scoring='balanced_accuracy'
        , cv=cv, n_jobs=1
    )
## ========================================================
with open(join(dir_root, 'MVPA', 'searchlight_surface.%s_hemi.r=5.pkl'%hemi), 'wb') as f:
    pickle.dump(Scores, f)
