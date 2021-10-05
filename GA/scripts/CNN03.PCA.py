#!/usr/bin/env python

#######################################################
import os
from os.path import join, dirname, exists
from glob import glob

import numpy as np

from tqdm import tqdm

import torchvision
from torchvision import transforms
from torchvision import models, utils

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA, IncrementalPCA
from sklearn.model_selection import KFold
from sklearn.model_selection import LeaveOneOut

import torch

import mydef
#######################################################
device = 'cuda:1' if torch.cuda.is_available() else 'cpu'
GA = mydef.GA()
seed = 42
#######################################################

def do_PCA_and_save(dir_activation, subj, stage, layer, dir_save, nframe, n_components=97):

    gg = 'GA' if 'early' in stage else ('GB' if 'late' in stage else 'invalid')
    runs = ['r01', 'r02', 'r03'] if 'practice' in stage else (['r04', 'r05', 'r06'] if 'unpractice' in stage else 'invalid')
    runs = np.array(runs)

    loo = LeaveOneOut()
    for idx_train, idx_test in loo.split(runs):
        run_test = runs[idx_test][0]
        ## test
        activations_file_list = glob(
                join(dir_activation,'%s.%s.*.%s.nframe%03d.npy'%(gg+subj,run_test,layer,nframe))
                )
        activations_file_list.sort()

        feature_dim = np.load(activations_file_list[0])
        x = np.zeros((len(activations_file_list),feature_dim.shape[0]))
        for i,activation_file in enumerate(activations_file_list):
            temp = np.load(activation_file)
            x[i,:] = temp

        x = StandardScaler().fit_transform(x)
        ipca = PCA(n_components=n_components,random_state=seed)
        x = ipca.fit_transform(x)
        np.save(join(dir_save,"%s.%s.%s.nframe%03d"%(gg+subj,run_test,layer,nframe)), x)
        np.save(join(dir_save,"%s.%s.%s.nframe%03d.explained_ratio"%(gg+subj,run_test,layer,nframe)), ipca.explained_variance_ratio_)

        ## train
        activations_file_list = []
        for run in runs[idx_train]:
            activations_file_list.append(glob(
                join(dir_activation,'%s.%s.*.%s.nframe%03d.npy'%(gg+subj,run,layer,nframe)))
                )
        activations_file_list = np.concatenate(activations_file_list)
        activations_file_list.sort()

        feature_dim = np.load(activations_file_list[0])
        x = np.zeros((len(activations_file_list),feature_dim.shape[0]))
        for i,activation_file in enumerate(activations_file_list):
            temp = np.load(activation_file)
            x[i,:] = temp

        x = StandardScaler().fit_transform(x)
        ipca = PCA(n_components=n_components,random_state=seed)
        x = ipca.fit_transform(x)
        np.save(
                join(dir_save,"%s.%sc.%s.nframe%03d"%(gg+subj,run_test,layer,nframe))
                , x)
        np.save(
                join(dir_save,"%s.%sc.%s.nframe%03d.explained_ratio"%(gg+subj,run_test,layer,nframe))
                , ipca.explained_variance_ratio_)
#######################################################
layers = ['layer%02d'%(i+1) for i in range(13)]

list_ = []
for subj in GA.list_subj:
    for layer in layers:
        list_.append([subj, layer])
list_ = np.array(list_)
#######################################################
stage = 'late_practice'
# preprocessing using PCA and save
print("-------------performing  PCA----------------------------")
for subj, layer in tqdm(list_):
    dir_activation = join(GA.dir_work,'results','activations','vgg16', subj)
    dir_save = join(GA.dir_work,'results','activations','vgg16','pca', subj)
    os.makedirs(dir_save, exist_ok=True)

    do_PCA_and_save(dir_activation, subj, stage, layer, dir_save, nframe=75)
