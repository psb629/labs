#!/usr/bin/env python
# coding: utf-8

# In[1]:

from os.path import join, exists
from os import makedirs
from glob import glob

import numpy as np
import pandas as pd

import pickle

from tqdm import tqdm

import json

from PIL import Image, ImageFilter

from sklearn.linear_model import Ridge
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.pipeline import Pipeline
from sklearn.model_selection import KFold

from scipy import stats

from nilearn import image, plotting, masking

from joblib import Memory


# In[2]:


from DRN import fmri


# In[3]:


DRN = fmri()


# ---

# In[5]:


import torch

# device = "cuda:1" if torch.cuda.is_available() else "cpu"
device = 'cpu'


# ---

# In[6]:

import argparse
parser = argparse.ArgumentParser()

parser.add_argument('-s','--subject', help="Subject ID")

args = parser.parse_args()

subj = args.subject

list_run = [ss.split('/')[-1] for ss in sorted(glob(join(DRN.dir_behav,subj,'Run?')))]

# ---

# In[7]:


scaler = StandardScaler()


# ---

# # Encoding model

# #### Network

# In[13]:


network = DRN.network


# ---

# #### Make a pipeline

# In[17]:


n_components = 100
pipeline_pca = Pipeline(
    [
        ('scaling', StandardScaler()),
        ('pca', PCA(n_components=n_components))
    ]
)


# ---

# #### Make matrix X

# In[18]:


dir_cache = join(DRN.dir_cache,'X')
makedirs(dir_cache, exist_ok=True)
memory = Memory(dir_cache, verbose=0)


# In[19]:


@memory.cache
def myfunc_X(subj, list_run, run, shift=0):
    ## design matrix X를 구성할 PC 열벡터들
    X = {}
    ## ======================== All indices ======================== ##
    _, idx_epi = DRN.get_idx_input(subj=subj, list_run=list_run, run=run, shift=shift)
    row = np.concatenate(list(idx_epi.values()))
    ## ======================== forward ======================== ##
    _, output_ = DRN.do_forward(subj=subj, list_run=list_run, run=run, shift=shift)
    (mu, std, v), (conv1, conv2, conv3) = output_
    ## ========================== PCA ========================== ##
    for jj, layer in enumerate([conv1, conv2, conv3]):
        lname = 'conv%1d'%(jj+1)
        key = (run, lname, shift)

        nsamples = layer.shape[0]
        assert len(row) == nsamples
        nfeatures = np.prod(layer.shape[1:])

        PCs = pipeline_pca.fit_transform(layer.reshape(nsamples,nfeatures))
        EV = np.cumsum(pipeline_pca['pca'].explained_variance_ratio_)
        X[(*key, 'Explained_Variance')] = EV

        ## 위 index들 외의 index들은 분석 불가능하므로, feature들을 0으로 둔다
        tmp = np.zeros((DRN.TPs, n_components))

        ## 분석 가능한 index에 순차적으로 PC들을 대입하여 X를 완성시킨다
        tmp[row] = PCs
        X[(*key, 'X')] = tmp
            
    return X


# In[20]:


X = {}
for run in list_run:
    for shift in [3, 4, 5, 6, 7, 8]:
        tmp = myfunc_X(subj, list_run=list_run, run=run, shift=shift)
        for key, value in tmp.items():
            X[key] = value


# In[21]:


tmp = []
for key in X.keys():
    tmp.append(key[2])
list_shift = np.unique(tmp)


# In[22]:


dict_X = {}
for run in list_run:
    for layer in ['conv%1d'%(ii+1) for ii in range(3)]:
        ## vector |1>
        tmp = np.ones((DRN.TPs, 1))
        for ii, shift in enumerate(list_shift):
            ## X' = [|1> X_(n) X_(n+1) X_(n+2) ...]
            tmp = np.concatenate(
                [tmp, X[(run,layer,shift,'X')]],
                axis=1
            )
        dict_X[(run,layer)] = tmp


# In[23]:


Xmat = {}
for layer in ['conv%1d'%(ii+1) for ii in range(3)]:
    print(layer)
    for ii, run in enumerate(list_run):
        if ii==0:
            tmp = dict_X[(run,layer)]
        else:
            tmp = np.concatenate(
                [tmp, dict_X[(run,layer)]],
                axis = 0
            )
    Xmat[layer] = tmp
    print(tmp.shape)

del dict_X, tmp


# ---

# ### fMRI data

# In[24]:


img_mask = glob(join(DRN.dir_mask,'mask.group.n*.frac=0.7.nii'))[-1]


# In[25]:


dir_cache = join(DRN.dir_cache,'apply_mask')
makedirs(dir_cache, exist_ok=True)
memory = Memory(dir_cache, verbose=0)


# In[26]:


@memory.cache
def myfunc_apply_mask(subj):
    Y = masking.apply_mask(
        imgs = join(DRN.dir_fmri,'preproc_data',subj,'errts.%s.tproject.nii'%subj),
        mask_img = img_mask
    )
    return Y


# In[27]:


Y = myfunc_apply_mask(subj)
(_, nvoxels) = Y.shape


# In[28]:


## reshape
Y = Y.reshape(len(list_run),DRN.TPs,nvoxels)

## normalization performed for each RUN
for ii, run in enumerate(list_run):
    if ii==0:
        tmp = scaler.fit_transform(Y[ii])
    else:
        tmp = np.concatenate(
            [tmp, scaler.fit_transform(Y[ii])],
            axis=0
        )
Y = tmp
Y = Y.reshape(len(list_run), DRN.TPs, nvoxels)


# Save the result as .nii

# In[32]:


dir_work = join(DRN.dir_fmri,'encoding_model',subj)
makedirs(dir_work, exist_ok=True)


# In[33]:


for rr, run in enumerate(tqdm(list_run)):
    fname = join(dir_work,'Y.r%02d.nii'%(rr+1))
    if not exists(fname):
        img = masking.unmask(
            X = Y[rr],
            mask_img = img_mask
        )
        img.to_filename(fname)


# In[34]:


for layer, x in Xmat.items():
    np.savetxt(
        fname = join(DRN.dir_fmri,'encoding_model',subj,'Xmat.%s.1D'%layer),
        X = Xmat[layer],
        fmt = '%.5e',
        delimiter = ' ',
        header='# list_shift=%s\n# The number of PC=%d'%(list_shift,n_components)
    )


# ---

# #### Ridge Regression

# In[35]:


from himalaya.ridge import RidgeCV

clf = RidgeCV(alphas=np.logspace(start=2, stop=12, num=11))
kf = KFold(n_splits=len(list_run), random_state=None, shuffle=False)


# In[36]:


from himalaya.backend import set_backend

# backend = set_backend('torch_cuda', on_error='warn')
backend = set_backend('cpu', on_error='warn')


# In[37]:


dir_cache = join(DRN.dir_cache,'Y_pred')
makedirs(dir_cache, exist_ok=True)
memory = Memory(dir_cache, verbose=0)


# In[38]:


@memory.cache
def myfunc_Y_pred(subj, list_run, Xmat2D, Y3D):
    ## Reshaping the matrix X (TPs, 1 + nruns*nPCs)
    Xmat3D = Xmat2D.reshape(len(list_run), DRN.TPs, -1)

    ## initializing Y_pred (nruns, TPs, nvoxels)
    Y_pred = np.zeros(Y3D.shape)
    
    ## learning
    for idx_train, idx_test in tqdm(kf.split(list_run)):
        ## Training
        beta = clf.fit(
            np.concatenate(Xmat3D[idx_train], axis=0),
            np.concatenate(Y3D[idx_train], axis=0)
        )

        ## Test
        Y_pred[idx_test[0]] = beta.predict(Xmat3D[idx_test[0]])
    
    return Y_pred


# Save the result as .nii

# In[39]:


dir_work = join(DRN.dir_fmri,'encoding_model',subj)
makedirs(dir_work, exist_ok=True)


# In[40]:


for layer, x in Xmat.items():
    Y_pred = myfunc_Y_pred(subj, list_run, Xmat2D=x, Y3D=Y)
    for rr, run in enumerate(list_run):
        img = masking.unmask(
            X = Y_pred[rr],
            mask_img = img_mask
        )
        img.to_filename(join(dir_work,'Y_pred.r%02d.%s.nii'%(rr+1,layer)))


# ---
