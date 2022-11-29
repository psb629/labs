import numpy as np
import re
from os.path import join
from glob import glob

#MNI
mni = np.array([[-36.00], [16.00], [54.00], [1.00]])


subj = 'GAB32'


with open(glob(join("*%s"%subj,"%s.anat.unifize.Xat.1D"%subj))[0], "r") as f:


affine = []
for line in lines:
    
    temp = np.array(re.findall(r'\S+',line))
    temp = temp.astype(np.float)
    
    affine.append(temp)
affine.append([0,0,0,1])
affine = np.array(affine)

#np.matmul
orig = np.matmul(affine, mni)
print(orig)

