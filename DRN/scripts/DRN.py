from os.path import join, exists
from os import makedirs
from glob import glob

import numpy as np

from tqdm import tqdm

import json

from PIL import Image

from joblib import Memory

import torch

from core.network import *

## ======================================================================== ##

class Common:

    def __init__(self):
        # device = "cuda:1" if torch.cuda.is_available() else "cpu"
        self.device = 'cpu'
        ## ======================================== ##
        self.dir_root = '/mnt/ext5/DRN'

        self.dir_behav = join(self.dir_root, 'behav_data')
        self.dir_reg = join(self.dir_behav, 'regressors/AM/value')

        self.dir_fmri = join(self.dir_root,'fmri_data')
        self.dir_mask = join(self.dir_fmri, 'masks')
        self.dir_model = join(self.dir_root,'model')
        
        self.dir_cache = join(self.dir_root, 'cache')
        
        self.resolution = (128,72)
        
class network(Common):
           
    def __init__(self):
        super().__init__()

        self.network = policy_value.ContinuousPolicyValue(D_in=(12,72,128), D_out=3, D_hidden=512, head='cnn')
        self.network.eval().to(self.device)

        self.ckpt = torch.load(
            join(self.dir_model,'drone_hanyang_mlagent.ppo/level2.ckpt')
            , map_location=self.device
        )

        self.network.load_state_dict(self.ckpt['network'])

## ======================================================================== ##

class behav(network):
    
    def __init__(self):
        super().__init__()

    def state_processing(self, obs):
        vis_obs = []

        for _obs in obs:
            ## _obs.shape = (1, 72, 128, 3)
            vis_obs.append(_obs)

        ## visual observation [(1, 72, 128, 3) x 4]
        vis_obs = np.concatenate(vis_obs, axis=-1)
        ## visual observation (1, 72, 128, 12)
        vis_obs = np.transpose(vis_obs, (0, 3, 1, 2))
        vis_obs = (vis_obs * 255).astype(np.uint8)

        ## visual observation (1, 12, 72, 128)
        return vis_obs

    def convert_time_to_sec(self, Time):
        m, s, ds = np.array(Time.split('-')).astype(int)
        return m*60+s+0.001*ds

    def get_data_behav(self, subj, list_run, resolution=(128,72)):

        self.dir_work = join(self.dir_behav,subj,'resized_%dx%d'%(resolution[0],resolution[1]))

        ## i) screen Shots
        dict_png = {}
        ## ii) actions
        behav = {}
        ## iii) onset times
        dict_onsettime = {}
        ## iv) onset times
        dict_action = {}
        ## v) episodes
        dict_episode = {}
        ## vi) results
        dict_result = {}
        for run in list_run:
            ## i)
            dict_png[run] = np.array(sorted(glob(join(self.dir_work,run,'*.png'))))
            ## ii)
            with open(join(self.dir_work,run,'log.json'),'r') as f:
                behav[run] = json.load(f)
    #         print('%s: actions (%d) / pngs (%d)'%(run, len(behav[run]), len(dict_png[run])))

            ## iii)
            tmp = []
            ## iv)
            tmp2 = []
            ## v)
            tmp3 = []
            ## vi)
            tmp4 = []
            for dict_ in behav[run]:
                tmp.append(self.convert_time_to_sec(dict_['Time']))
                tmp2.append(dict_['Action'])
                tmp3.append(dict_['Episode'])
                tmp4.append(dict_['PrevEpisodeResult'])
            dict_onsettime[run] = np.array(tmp)
            dict_action[run] = np.array(tmp2)
            dict_episode[run] = np.array(tmp3)
            dict_result[run] = np.array(tmp4)

        return dict_png, dict_onsettime, dict_action, dict_episode, dict_result
    
## ======================================================================== ##

class fmri(behav):
      
    def __init__(self):
        super().__init__()
        
        ## time points per a run
        self.TR = 0.5
        self.TPs = 1400

    def get_idx_input(self, subj, list_run, run, shift=0):
        nFrameStack = 4
        TR = 0.5

        _, dict_onsettime, _, _, _ = self.get_data_behav(subj,list_run)

        onsettimes = dict_onsettime[run]
        onsettimes = onsettimes[onsettimes<700-shift]

        ## A set of the last indices for each episode except the last episode
        idx_final = np.concatenate([np.where(np.diff(onsettimes)>TR)[0], [onsettimes.shape[0]-1]])
        idx_initial = np.concatenate([[0],idx_final[:-1]+1])
        assert idx_initial.shape == idx_final.shape

        idx_input = {}
        idx_epi = {}
        for ii, (idx_i, idx_f) in enumerate(zip(idx_initial, idx_final)):
            episode = 'episode:%02d'%(ii+1)

            ## the times of the initial and final frame
            ta, tb = onsettimes[idx_i], onsettimes[idx_f]
            ## the number of frames at the episode
            n_frame = int(idx_f-idx_i+1)

            ## The fMRI image corresponding to the first frame of this episode
            a = ta - ta%TR
            ## The fMRI image corresponding to the final frame of this episode
            b = tb - tb%TR

            ## The number of fMRI images representing the corresponding episode.
            n_epi = int((b-a)/TR + 1)
            if n_epi <= 1:
                continue

            ## The fMRI indices that make up each episode
            timepoint_epi = np.arange(a,b+TR,TR)+shift
            timepoint_epi = timepoint_epi[timepoint_epi<700]
            idx_epi[episode] = (2*(timepoint_epi-6)).astype(int)

            ## an input set to forward via a model
            idx_input[episode] = np.zeros((n_epi,nFrameStack)).astype(int)

            ## the last input
            idx_input[episode][-1] = [idx_f-nFrameStack+1+jj for jj in range(nFrameStack)]

            ## the rest of them
            didx = (idx_f-nFrameStack-idx_i)*TR/(b-a+1.e-8)
            for jj in range(n_epi-1):
                idx_input[episode][jj] = [int(idx_i+didx*jj+kk) for kk in range(nFrameStack)]

        for episode, input_ in idx_input.items():
            assert input_.shape[0] == idx_epi[episode].shape[0]

        return idx_input, idx_epi

    def do_forward(self, subj, list_run, run, shift=0):
        ## ======================= setup ======================= ##
        dict_png, _, _, _, _ = self.get_data_behav(subj=subj, list_run=list_run)
        idx_input, idx_epi = self.get_idx_input(subj=subj, list_run=list_run, run=run, shift=shift)

        for ii, (episode, indices) in enumerate(idx_epi.items()):
            ## 해당 EPI index에 매칭되는 png의 index들
            tmp = idx_input[episode]

            ## 해당 RUN에 input으로 쓰일 모든 png fname 들
            if ii > 0:
                input_fname = np.concatenate(
                    [
                        input_fname,
                        dict_png[run][tmp]
                    ],
                    axis=0
                )
            else:
                input_fname = dict_png[run][tmp]

        ## (batch size of Run, 4)
        (batch, _) = input_fname.shape

        ## ======================= input ======================= ##
        ## Actual input values to be entered into the network
        input_ = np.zeros((batch,12,72,128), dtype=np.uint8)

        for timepoint, fnames in enumerate(tqdm(input_fname)):
            ## 4 frames (1,72,128,3) 를 numpy 로 불러와서 쌓음
            tmp = np.stack(
                [np.asarray(Image.open(f)).reshape((1,72,128,3)) for f in fnames],
                axis=0
            )

            ## 이미지 전처리 (4, 1, 72, 128, 3) -> (12, 72, 128, 3)
            input_[timepoint] = self.state_processing(tmp)

        del tmp
        ## 이미지를 torch.tensor 로 변경
        input_ = torch.from_numpy(input_)
        ## ========================== Forward ========================== ##
        ## 쌓은 frame 들을 network에 입력
        with torch.no_grad():
            output_ = self.network(input_.to(self.device))

        return input_, output_

## ======================================================================== ##