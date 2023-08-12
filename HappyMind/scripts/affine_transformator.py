#!/usr/bin/env python3

 #auto_warp.py -base TT_N27.nii -input MNI152_2009_template.nii -skull_strip_input no

## ========================================================= ##
from os.path import join
from glob import glob
import numpy as np
import argparse
import re
## ========================================================= ##
## ArgumentParser 객체 생성
parser = argparse.ArgumentParser()

## 옵션 목록
parser.add_argument('-s','--subject', help="Subject ID")
parser.add_argument('-d','--dir_data', help="The directory location of data")
parser.add_argument('-o','--order', default='lpi', help="RAI vs. LPI (default)")
parser.add_argument('-m','--master', default='orig', help="Orig (default) vs. MNI")
parser.add_argument('--xyz', help="coordinate, e.g.) '-15.241 18.516 9.663'")
## ========================================================= ##
## 명령줄 인자 파싱
args = parser.parse_args()

subj = args.subject
order = args.order.upper()
master = args.master.lower()
assert (master=='orig')|(master=='mni')
xyz = np.array(re.findall(r"[-+]?\d*\.\d+|[-+]?\d+", args.xyz), dtype='float')
assert len(xyz)==3
xyz = np.concatenate([xyz,[1]]).reshape(4,1)
## ========================================================= ##
dir_work = args.dir_data
## ========================================================= ##
## Affine Trasformation Matrix (MNI to Orig)
aff1D = np.loadtxt(
            join(dir_work,'warp.%s.anat.Xat.1D'%subj),
            dtype='float', delimiter=None
        )
aff2D = np.vstack([aff1D.reshape(3,4), [0, 0, 0, 1]])
aff2D_inverted = np.linalg.inv(aff2D)
if master=='orig':
    G = aff2D_inverted
elif master=='mni':
    G = aff2D
## ========================================================= ##
M = np.zeros((4,4))
M[3,3] = 1
for ii, oo in enumerate(order):
    if (oo=='R')|(oo=='A')|(oo=='I'):
        M[ii,ii] = 1
    elif (oo=='L')|(oo=='P')|(oo=='S'):
        M[ii,ii] = -1       
G = np.matmul(np.linalg.inv(M),G)
G = np.matmul(G,M)
## ========================================================= ##
res = np.matmul(G,xyz)

print(res[:3])
