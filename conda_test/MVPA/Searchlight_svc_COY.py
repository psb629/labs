import nilearn.image, nilearn.decoding

import numpy as np
import pandas as pd

from sklearn.svm import LinearSVC
from sklearn.model_selection import GroupKFold

def get_label_index_answer(subj, run):
    ## labeling betas of answer's indices ##
    # number of betas
    n_betas = 3
    # target betas whose number starts from 1. i.e.) beta_1, beta_2, ...,
    target_betas = [1,2]

    df = pd.read_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svc.dat' % (subj, run), sep='\t', dtype='float64', na_values='NaN')

    temp = [a if b == 1 else 3-a for a,b in zip(df['Freq.other.index'],df['Freq.other_answer.class'])]
    index = [i*n_betas - 1 + target_betas[0] if x == 1 else i*n_betas - 1 + target_betas[1] for i, x in enumerate(temp)]
    
    return index

def load_beta_image_answer(subj, run):
    ## load nilearn image ##
    ## nii.gz 추천. HEAD/BRIK 은 load 안 되는 것 같음. ##

    img = nilearn.image.load_img(stats_dir + subj + '/r0%d.LSSout.nii.gz' % (run))

    index_answer = get_label_index_answer(subj, run)    
    img_answer = nilearn.image.index_img(img, index_answer)

    return img_answer

def load_target_answer(subj, run):
    # load behavior data and make up them

    df = pd.read_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svc.dat' % (subj, run), sep='\t', dtype='float64', na_values='NaN')
    temp = list(df['Freq.other_answer.class'])

    return temp

def get_X_y_group_answer(subj, runs):
    Xs = [
        load_beta_image_answer(subj, run)
        for run in runs
    ]
    ys = [
        load_target_answer(subj, run)
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

def get_label_index_decision(subj, run):
    ## labeling betas of decision's indices ##
    # number of betas
    n_betas = 3
    # target betas whose number starts from 1. e.g.) beta_1, beta_2, ...,
    target_betas = [1,2]

    df = pd.read_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svc.dat' % (subj, run), sep='\t', dtype='float64', na_values='NaN')
    
    temp = [0 if pd.isna(b) else (a if b == 1 else 3-a) for a,b in zip(df['Freq.other.index'],df['Freq.other_decision.class'])]
    index = ['NaN' if x==0 else (i*n_betas - 1 + target_betas[0] if x == 1 else i*n_betas - 1 + target_betas[1]) for i, x in enumerate(temp)]
    
    cleaned_index = [x for x in index if x != 'NaN']

    #num_nan = 0
    #for x in decision:
    #    if pd.isna(x):
    #        num_nan = num_nan + 1
    #print(num_nan)

    return cleaned_index

def load_beta_image_decision(subj, run):
    ## load nilearn image ##
    ## nii.gz 추천. HEAD/BRIK 은 load 안 되는 것 같음. ##

    img = nilearn.image.load_img(stats_dir + subj + '/r0%d.LSSout.nii.gz' % (run))

    index_decision = get_label_index_decision(subj, run)
    img_decision = nilearn.image.index_img(img, index_decision)
    
    return img_decision

def load_target_decision(subj, run):
    # load behavior data and make up them

    df = pd.read_csv(behav_dir + subj + '/%s.r%02d.Dis_classes_for_svc.dat' % (subj, run), sep='\t', dtype='float64', na_values='NaN')
    temp = list(df['Freq.other_decision.class'])
    
    cleaned_class = [x for x in temp if not pd.isna(x)]

    return cleaned_class

def get_X_y_group_decision(subj, runs):
    Xs = [
        load_beta_image_decision(subj, run)
        for run in runs
    ]
    ys = [
        load_target_decision(subj, run)
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
    scoring='balanced_accuracy'
    )

    searchlight.fit(X, y, group)
    scores = searchlight.scores_ - chance_level

    return nilearn.image.new_img_like(full_mask, scores)

#################################################################################
behav_dir = '/clmnlab/TM/behav_data/'
stats_dir = '/clmnlab/TM/fMRI_data/stats/Reg7_MVPA3_IM_COY/'
preproc_dir = '/clmnlab/TM/fMRI_data/preproc_data/'
result_dir = '/clmnlab/TM/fMRI_data/MVPA/sungbeen/'

subj_list = [
				"TML04_PILOT","TML05_PILOT","TML06_PILOT","TML07_PILOT"
				,"TML08_PILOT","TML09_PILOT","TML10_PILOT","TML11_PILOT"
				,"TML12_PILOT","TML13","TML14","TML15","TML16","TML18"
			]

for subj in subj_list:
    runs = [1,2,3]
    fullmask_datum = preproc_dir + subj + '/preprocessed/full_mask.%s.nii.gz' % (subj)
    #n_subj = len(subj_list)

    # full mask 를 사용하시면 됩니다. 여기에서는 processing time 줄이려고 작은 마스크 가져옴.
    print("Loading %s's mask_img..." % (subj))
    mask_img = nilearn.image.load_img(fullmask_datum)
    print("Done!")

    estimator = LinearSVC(max_iter=10000)
    estimator_name = 'svc'
    radius = 8  # 적절한 크기를 사용하세요.
    
    #pd.show_versions()

    print("Executing searchlight_svc_updown")
    X, y, group = get_X_y_group_answer(subj, runs)
    searchlight_img = run_searchlight(mask_img, X, y, group, group_k=3, estimator=estimator, radius=radius, chance_level=1/2)
    searchlight_img.to_filename(result_dir + '%s_r%d_updown_%s.nii.gz' % (subj, radius, estimator_name))
    
    print("Executing searchlight_svc_decision")
    X, y, group = get_X_y_group_decision(subj, runs)
    searchlight_img = run_searchlight(mask_img, X, y, group, group_k=3, estimator=estimator, radius=radius, chance_level=1/2)
    searchlight_img.to_filename(result_dir + '%s_r%d_decision_%s.nii.gz' % (subj, radius, estimator_name))
    
    print('%s finished' % (subj))
