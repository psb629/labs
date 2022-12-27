#!/usr/bin/env python3

 #auto_warp.py -base TT_N27.nii -input MNI152_2009_template.nii -skull_strip_input no

from os.path import join
from glob import glob
import numpy as np
import sys

if ('-xyz' in sys.argv):
    idx = sys.argv.index('-xyz')
elif ('-mni' in sys.argv):
    idx = sys.argv.index('-mni')
coord = np.concatenate([sys.argv[idx+1:idx+4], [1]]).astype(float).reshape(4,1)
print(coord)

dir_root = '/mnt/ext5/SMC/fmri_data/tmp/awpy'

fname = glob(join(dir_root,'*.Xaff12.1D'))[0]
## Mt*Input = Base
aff1D = np.loadtxt(fname, dtype='float', delimiter=None)
## Mt
aff2D = np.vstack([aff1D.reshape(3,4), [0, 0, 0, 1]])
## M
aff2D_inverted = np.linalg.inv(aff2D)

print(aff2D)
print(aff2D_inverted)

result = np.matmul(aff2D, coord)
print(result)
result = np.matmul(aff2D_inverted, coord)
print(result)
