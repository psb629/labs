#!/usr/bin/env python

#######################################################
import os
from os.path import join, dirname, exists

import numpy as np
import pandas as pd

import nilearn
import nibabel

from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import LeaveOneOut

from tqdm import tqdm

import torch

## import mydef as my Class correction for projects
import mydef

#######################################################
device = 'cuda:1' if torch.cuda.is_available() else 'cpu'
GA = mydef.GA()
seed = 42
#######################################################
class OLS_pytorch(object):
    def __init__(self,use_gpu=False):
        self.coefficients = []
        self.use_gpu = use_gpu
        self.X = None
        self.y = None

    def _reshape_x(self,X):
        ## 열벡터로 변환
        return X.reshape(-1,1)

    def _concatenate_ones(self,X):
        ## [x] -> [1 x]
        ones = np.ones(shape=X.shape[0]).reshape(-1,1)
        return np.concatenate((ones,X),1)

    def fit(self,X,y):
        ## 행벡터 인가?
        if len(X.shape) == 1:
            X = self._reshape_x(X)
        if len(y.shape) == 1:
            y = self._reshape_x(y)
        ## X = [1 X] -> X.shape = (nvideo, 100+1)
        X = self._concatenate_ones(X)

        X = torch.from_numpy(X).float()
        ## y.shapy = (nvideo, nvoxel)
        y = torch.from_numpy(y).float()
        if self.use_gpu:
 #            X = X.to()
            X = X.cuda(device)
 #            y = y.cuda()
            y = y.to(device)
        XtX = torch.matmul(X.t(),X)
        Xty = torch.matmul(X.t(),y.unsqueeze(2))
        XtX = XtX.unsqueeze(0)
        XtX = torch.repeat_interleave(XtX, y.shape[0], dim=0)
        ## XtX * betas = XtX
        ## ()
        betas_cholesky, _ = torch.solve(Xty, XtX)
 #        betas_cholesky = torch.linalg.solve(XtX, Xty)

        self.coefficients = betas_cholesky

    def predict(self, entry):
        if len(entry.shape) == 1:
            entry = self._reshape_x(entry)
            ## -> entry : 열벡터
        entry = self._concatenate_ones(entry)
        ## -> entry : [1 entry]
        entry = torch.from_numpy(entry).float()
        if self.use_gpu:
 #            entry = entry.cuda()
            entry = entry.to(device)
        prediction = torch.matmul(entry,self.coefficients)
        ## prediction = [1 entry] * betas = (N * 2) * ()
        prediction = prediction.cpu().numpy()
        prediction = np.squeeze(prediction).T

        return prediction

def predict_fmri_fast(train_activations, test_activations, train_fmri, use_gpu=False):
    """This function fits a linear regressor using train_activations and train_fmri,
    then returns the predicted fmri_pred_test using the fitted weights and
    test_activations.
    Parameters
    ----------
    train_activations : np.array
        matrix of dimensions (#train_vids) x (#pca_components)
        containing activations of train videos.
    test_activations : np.array
        matrix of dimensions (#test_vids) x (#pca_components)
        containing activations of test videos
    train_fmri : np.array
        matrix of dimensions (#train_vids) x (#voxels)
        containing fMRI responses to train videos
    use_gpu : bool
        Description of parameter `use_gpu`.
    Returns
    -------
    fmri_pred_test: np.array
        matrix of dimensions (#test_vids) x (#voxels)
        containing predicted fMRI responses to test videos .
    """
    reg = OLS_pytorch(use_gpu)
    reg.fit(train_activations, train_fmri.T)
    fmri_pred_test = reg.predict(test_activations)

    return fmri_pred_test

def get_activations(dir_pca, run, layer, nframe):
    """This function loads neural network features/activations (preprocessed using PCA) into a
    numpy array according to a given layer.
    Parameters
    ----------
    dir_pca : str
        Path to PCA processed Neural Network features
    layer : str
        which layer of the neural network to load,
    Returns
    -------
    train_activations : np.array
        matrix of dimensions #train_vids x #pca_components
        containing activations of train videos
    """

    train_file = join(dir_pca,'%sc.%s.nframe%03d.npy'%(run,layer,nframe))
    train_activations = np.load(train_file)
    scaler = StandardScaler()
    train_activations = scaler.fit_transform(train_activations)

    test_file = join(dir_pca,'%s.%s.nframe%03d.npy'%(run,layer,nframe))
    test_activations = np.load(test_file)
    scaler = StandardScaler()
    test_activations = scaler.fit_transform(test_activations)

    return train_activations, test_activations

def get_fmri(file_fmri, img_mask):

    img = nilearn.image.load_img(file_fmri)
    masked_img = GA.fast_masking(img=img, roi=img_mask)
    masked_img = StandardScaler().fit_transform(masked_img)

    return masked_img

#@title Utility functions for regression
def vectorized_correlation(x,y):
    ## 베셀 보정 (n-1) 한 Pearson correlation
    dim = 0

    centered_x = x - x.mean(axis=dim, keepdims=True)
    centered_y = y - y.mean(axis=dim, keepdims=True)

    covariance = (centered_x * centered_y).sum(axis=dim, keepdims=True)

    bessel_corrected_covariance = covariance / (x.shape[dim] - 1)

    x_std = x.std(axis=dim, keepdims=True)+1e-8
    y_std = y.std(axis=dim, keepdims=True)+1e-8

    corr = bessel_corrected_covariance / (x_std * y_std)

    return corr.ravel()

def saveasnii(nii_mask, fname, data3Darray):
    nii_data = nibabel.Nifti1Image(data3Darray, nii_mask.affine, nii_mask.header)
    nibabel.save(nii_data, fname)

#######################################################
print("Loading ROI images...")
GA.load_fan()

 ### yeo_17network == 1
 #dt = pd.DataFrame()
 #for nn in [1]:
 #    dt = dt.append(GA.fan_info[(GA.fan_info.yeo_17network == nn)])
 #for idx in dt.index:
 #    nn = dt.loc[idx,'label']
 #    region = dt.loc[idx,'region']
 #    GA.roi_imgs[region] = GA.fan_imgs[str(nn)]

## full mask
GA.roi_imgs['fullmask'] = nilearn.image.load_img(join(GA.dir_mask,'full_mask.GAGB.nii.gz'))
#######################################################
layers = ['layer%02d'%(i+1) for i in range(13)]
runs = ['r%02d'%(i+1) for i in range(3)]
loo = LeaveOneOut()

temp = []
for i, (idx_train, idx_test) in enumerate(loo.split(runs)):
    temp.append((runs[idx_train[0]], runs[idx_train[1]], runs[idx_test[0]]))
    
list_ = []
for subj in GA.list_subj:
    for a,b,c in temp:
        for layer in layers:
            list_.append([subj, a,b,c, layer])

list_ = np.array(list_)

dir_pca = join(GA.dir_work,'results','activations','vgg16','pca')
dir_output = join(dir_pca, 'eval')
os.makedirs(dir_output, exist_ok=True)

nframe = 75

stage = 'late_practice'
gg = 'GA' if 'early' in stage else ('GB' if 'late' in stage else 'invalid')

previous = {}
for c in ['subj', 'r_test']:
    previous[c] = 0

roi = 'fullmask'
img_mask = GA.roi_imgs[roi]
for i, (subj, r_train1, r_train2, r_test, layer) in enumerate(tqdm(list_)):

    file_output = join(dir_output, subj, 'score.%s.%s.%s.%s%s.nii'%(r_test, roi, layer, gg, subj))
    if exists(file_output):
        continue

    if previous['subj']!=subj or previous['r_test']!=r_test:
        ## load real fmri data
        file_fmri = join(GA.dir_fmri, 'preproc_data', subj,'betasLSS.%s%s.%s.nii.gz'%(gg, subj, r_test))
        real_fmri = get_fmri(file_fmri, img_mask)
       
        ## load train fmri data & concatenate them
        file_fmri = join(GA.dir_fmri, 'preproc_data', subj,'betasLSS.%s%s.%s.nii.gz'%(gg, subj, r_train1))
        train1_fmri = get_fmri(file_fmri, img_mask)
        file_fmri = join(GA.dir_fmri, 'preproc_data', subj,'betasLSS.%s%s.%s.nii.gz'%(gg, subj, r_train2))
        train2_fmri = get_fmri(file_fmri, img_mask)

        concat_fmri = np.r_[train1_fmri, train2_fmri]

    ## load activations
    train_activations, test_activations = get_activations(join(dir_pca, subj), r_test, layer, nframe)

    ## calculated predict fmri
    pred_fmri = predict_fmri_fast(train_activations, test_activations, concat_fmri, use_gpu=device)

    ## evaluation
    score = vectorized_correlation(real_fmri, pred_fmri)

    score3D = np.zeros(img_mask.shape)
    score3D[img_mask.get_fdata().astype(bool)] = score

    saveasnii(img_mask, file_output, score3D)

    previous['subj'] = subj
    previous['r_test'] = r_test
