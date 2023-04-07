#!/usr/bin/env python

import getpass
from sys import platform
import os
from os.path import exists, join
from glob import glob
import numpy as np
import re
from tqdm import tqdm
import shutil
##===================================================##
subj = 'S37'
date = '211117'
##===================================================##
username = getpass.getuser()
print("OS :",platform)
if platform == "linux" or platform == "linux2":
    # linux
    dir_root = join('/home',username,'Desktop')
elif platform == "darwin":
    # OS X
    dir_root = join('/Users',username,'Desktop')

dir_raw = join(dir_root, '%s_%s'%(subj, date))
dir_output = join(dir_root, 'preprocessed', subj)
os.makedirs(dir_output, exist_ok=True)
##===================================================##
## EPI (18000)
### 5 자릿수로 만들기
list_ = glob(join(dir_raw, 'epi', '*.dcm'))
for ss in list_:
    string = ss.split('/')[-1].replace(subj, '')
    num = re.findall(r'\d+', string)[0]
    to_ = ss.replace('%s.dcm'%num, '%05g.dcm'%int(num))
    os.rename(ss, to_)
### 300(시간)차이 나는 파일끼리 60묶음(공간)으로 번호 재배옇
dir_tmp = join(dir_raw, 'tmp')
os.makedirs(dir_tmp, exist_ok=True)
os.chdir(join(dir_raw, 'epi'))
set_time = range(300)
cnt = 0
for t_ini in set_time:
    timeseries = range(t_ini, 18000, 300)
    list_ = []
    for nn in timeseries:
        from_ = join(dir_raw, 'epi/%s.dcm%05g.dcm'%(subj,nn+1))
        to_ = join(dir_tmp, 'epi_rearranged.%05d.dcm'%(cnt+1))
        os.system('cp %s %s'%(from_, to_))
        #to_ = join('./epi_rearranged.%05g.dcm'%(cnt+1))
        #os.rename(from_, to_)
        #print('%s -> %s'%(from_, to_))
        cnt += 1
    os.system('dcm2niix_afni -o %s -s y -f "%03d" %s'%(dir_tmp, t_ini, dir_tmp))
    list_ = glob(join(dir_tmp, '*.dcm'))
    for ss in list_:
        os.remove(ss)
os.system('3dTcat -tr 2 -prefix %s/%s_epi.nii %s/*.nii'%(dir_output, subj, dir_tmp))
shutil.rmtree(dir_tmp)
##===================================================##
## T1 (365)
dir_tmp = join(dir_raw, 't1')
os.system('dcm2niix_afni -o %s -s y -f "%s_t1" %s'%(dir_output, subj, dir_tmp))
