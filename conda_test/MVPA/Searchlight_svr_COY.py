import nilearn.image, nilearn.decoding

import numpy as np
import pandas as pd

from sklearn.svm import LinearSVR
from sklearn.model_selection import GroupKFold

#!pushd \\10.201.185.39\clmnlab

#################################################################################
#behav_dir = '/clmnlab/TM/behav_data/'
#stats_dir = '/clmnlab/TM/fMRI_data/stats/Reg7_MVPA3_IM_COY/'
#preproc_dir = '/clmnlab/TM/fMRI_data/preproc_data/'
#result_dir = '/clmnlab/TM/fMRI_data/MVPA/sungbeen/'
behav_dir = 'Z:/TM/behav_data/'
stats_dir = 'Z:/TM/fMRI_data/stats/Reg7_MVPA3_IM_COY/'
preproc_dir = 'Z:/TM/fMRI_data/preproc_data/'
result_dir = 'Z:/TM/fMRI_data/MVPA/sungbeen/'
#################################################################################

def get_label_index(subj, run):
    ## labeling betas in a group of freq_other ##
    # number of betas in each trial
    n_betas = 3 # freq.1, freq.2, yellow
    # target betas whose number startsjj from 1. i.e.) beta_1, beta_2, ...,
    target_betas = [1,2]

    df = pd.read_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svr.dat' % (subj, run), sep='\t', dtype='int64')

    index = [i*n_betas - 1 + target_betas[0] if x == 1 else i*n_betas - 1 + target_betas[1] for i, x in enumerate(df['Freq.other.index'])]
    
    return index

def load_beta_image(subj, run):
    ## load nilearn image ##
    ## nii.gz 추천. HEAD/BRIK 은 load 안 되는 것 같음. ##

    img_temp = nilearn.image.load_img(stats_dir + subj + '/r0%d.LSSout.nii.gz' % (run))

    index = get_label_index(subj, run)    
    img = nilearn.image.index_img(img_temp, index)

    return img

def load_target(subj, run):
    # load behavior data and make up them

    df = pd.read_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svr.dat' % (subj, run), sep='\t', dtype='int64')
    temp = list(df['Freq.other_updown.class'])
    
    assert sum(temp)==0

    return temp

def get_X_y_group(subj, runs):
    Xs = [
        load_beta_image(subj, run)
        for run in runs
    ]
    ys = [
        load_target(subj, run)
        for run in runs
    ]
    group = [
        i for i, y in enumerate(ys) for j in range(len(y))
    ]
    Xs = nilearn.image.concat_imgs(Xs)
    ys = np.concatenate(ys)

    assert Xs.shape[-1] == ys.shape[0]
    assert ys.shape[0] == len(group)

    return Xs, ys, group

def run_searchlight(full_mask, X, y, group, estimator, group_k, radius, chance_level):
    cv = GroupKFold(group_k)

    searchlight = nilearn.decoding.SearchLight(
    full_mask,
    radius=radius,
    estimator=estimator,
    n_jobs=4,
    verbose=False,
    cv=cv,
    scoring='explained_variance'
    )

    searchlight.fit(X, y, group)
    scores = searchlight.scores_ - chance_level

    return nilearn.image.new_img_like(full_mask, scores)

#################################################################################
subj_list = [
                "TML04_PILOT","TML05_PILOT","TML06_PILOT","TML07_PILOT"
                ,"TML08_PILOT","TML09_PILOT","TML10_PILOT","TML11_PILOT"
                ,"TML12_PILOT","TML13","TML14","TML15","TML16","TML18"
            ]
runs = [1,2,3]
#pd.show_versions()
#################################################################################
for subj in subj_list:
    path_mask = 'Z:/TM/fMRI_data/stats/Reg8_GLM_vibration_vs_yellow/' + subj + '/Clust_mask_binary.%s.nii.gz' % (subj)
    #mask_cluster = '/clmnlab/TM/fMRI_data/stats/Reg8_GLM_vibration_vs_yellow/' + subj + '/Clust_mask.%s.nii.gz' % (subj)

    # full mask 를 사용하시면 됩니다. 여기에서는 processing time 줄이려고 작은 마스크 가져옴.
    print("Loading %s's mask_img..." % (subj))
    mask_img = nilearn.image.load_img(path_mask)
    print("Done!")

    estimator = LinearSVR(max_iter=10000)
    estimator_name = 'svr'
    radius = 8  # 적절한 크기를 사용하세요.

    print("Executing searchlight_svr_updown")
    X, y, group = get_X_y_group(subj, runs)
    print(X)
    print(y,len(y))
    print(group,len(group))
    searchlight_img = run_searchlight(mask_img, X, y, group, group_k=3, estimator=estimator, radius=radius, chance_level=0.1)
    searchlight_img.to_filename(result_dir + '%s_r%d__%s+masked.nii.gz' % (subj, radius, estimator_name))
        
    print('%s finished' % (subj))