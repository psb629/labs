#!/usr/bin/env python

#######################################################
import os
from os.path import join, dirname, exists
from glob import glob

import numpy as np
import pandas as pd

import random

from tqdm import tqdm

import torchvision
from torchvision import transforms
from torchvision import models, utils

import torch
import torch.nn as nn
import torch.utils.model_zoo as model_zoo
import torch.nn.functional as F
from torch.autograd import Variable as V
from PIL import Image
from decord import VideoReader
from decord import cpu

## import mydef as my Class correction for projects
import mydef
#######################################################
device = 'cuda:1' if torch.cuda.is_available() else 'cpu'
GA = mydef.GA()
seed = 42
#######################################################
## r2d
# model = models.resnet18(pretrained=True)
## r3d
# model = models.video.r3d_18(pretrained=True)
## vgg16
model = models.vgg16(pretrained=True)

from torchsummary import summary
summary(model=model.to('cuda'), input_size=(3, 224, 224), device='cuda')

def vgg16(net, _input):
    outs = {}
    outs['1'] = net.features[:2](_input)
    outs['2'] = net.features[2:5](outs['1'])
    outs['3'] = net.features[5:7](outs['2'])
    outs['4'] = net.features[7:10](outs['3'])
    outs['5'] = net.features[10:12](outs['4'])
    outs['6'] = net.features[12:14](outs['5'])
    outs['7'] = net.features[14:17](outs['6'])
    outs['8'] = net.features[17:19](outs['7'])
    outs['9'] = net.features[19:21](outs['8'])
    outs['10'] = net.features[21:24](outs['9'])
    outs['11'] = net.features[24:26](outs['10'])
    outs['12'] = net.features[26:28](outs['11'])
    outs['13'] = net.features[28:](outs['12'])
    
    return outs
#######################################################
def sample_video_from_mp4(vpath, num_frames=15):
    """This function takes a mp4 video vpath as input and returns
    a list of uniformly sampled frames (PIL Image).
    Parameters
    ----------
    vpath : str
        path to mp4 video vpath
    num_frames : int
        how many frames to select using uniform frame sampling.
    Returns
    -------
    images: list of PIL Images
    num_frames: int
        number of frames extracted
    """
    images = list()
    vr = VideoReader(vpath, ctx=cpu(0))
    total_frames = len(vr)
    indices = np.linspace(0,total_frames-1,num_frames,dtype=int)
    for seg_ind in indices:
        images.append(Image.fromarray(vr[seg_ind].asnumpy()))

    return images, num_frames

#@title Functions for loading videos and extracting features
# Torch RNG
torch.manual_seed(seed)
torch.cuda.manual_seed(seed)
torch.cuda.manual_seed_all(seed)
# Python RNG
np.random.seed(seed)
random.seed(seed)

def get_activations_and_save(model, subj, stage, run, dir_activation, ITI=5, down_sample = 0.25, device=device):
    
    ## down sampling: 60Hz * 0.25
    dir_output = join(dir_activation, subj)
    os.makedirs(dir_output, exist_ok=True)
    
    gg = 'GA' if 'early' in stage else ('GB' if 'late' in stage else 'invalid')
    model.to(device)
    
    resize_normalize = transforms.Compose([
            transforms.Resize((224,224))
            , transforms.ToTensor()
            , transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])])
    
    ## a number of total frames: 29100
    total_frame = int(60*5*97)
    
    ## a number of frames per trial
    nframe = int(total_frame*down_sample/97.)

    video, num_frames = sample_video_from_mp4(
        vpath=join(GA.dir_work,'videos','20210914.%s%s.%s.mp4'%(gg, subj, run))
        , num_frames=int(total_frame*down_sample)
    )
    trial = 0
    for frame, img in enumerate(video):
        ## is it the 1st frame of each trial?
        is_1st = frame % (down_sample*60*ITI) == 0
        ## is it the last frame of each trial?
        is_last = (frame+1) % (down_sample*60*ITI) == 0

        ## at the 1st frame of a trial
        if is_1st:
            trial += 1
            activations = []

#         if trial != 84:
#             continue
            
        input_img = V(resize_normalize(img).unsqueeze(0))
        input_img = input_img.to(device)

        out = vgg16(net=model, _input=input_img)
        for i, feature in out.items():
            if is_1st:
                activations.append(feature.data.cpu().numpy().ravel())
            else:
                activations[int(i)-1] =  activations[int(i)-1] + feature.data.cpu().numpy().ravel()

        ## at the end of a trial
        if is_last:
            for layer in range(len(activations)):
                avg_layer_activation = activations[layer]/float(down_sample*60*ITI)
                fin_output = join(dir_output,"%s.%s.trial%02d.layer%02d.nframe%03d.npy"%(gg+subj,run,trial,layer+1,nframe))
                np.save(fin_output, avg_layer_activation)
#######################################################
## get and save activations
dir_activation = join(GA.dir_work,'results','activations','vgg16')
os.makedirs(dir_activation, exist_ok=True)

list_ = []
stage = 'late_practice'
for subj in GA.list_subj:
    for run in ['r01', 'r02', 'r03']:
        list_.append([subj, stage, run])

print("-------------Saving activations ----------------------------")
for subj, stage, run in tqdm(list_):
#     fin_output = join(dir_output,"%s.%s.trial%02d.layer%02d.nframe%03d.npy"%(gg+subj,run,trial,layer+1,nframe))
#     if exists(fin_output):
#         continue
    get_activations_and_save(
        model=model, subj=subj, stage=stage, run=run
        , dir_activation=dir_activation, down_sample=.25, device=device)