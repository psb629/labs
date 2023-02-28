#!/bin/env python

import numpy as np
from PIL import Image
from os import makedirs
from os.path import join, exists
from glob import glob
import sys
import shutil

if ('-s' in sys.argv):
    idx = sys.argv.index('-s')
elif ('--subj' in sys.argv):
    idx = sys.argv.index('--subj')
subj=str(sys.argv[idx+1])

dir_root = join("/mnt/ext5/DRN/behav_data", subj)
if not exists(dir_root):
    raise Exception(" %s doesn't exist!"%dir_root)

list_dir_run = sorted(glob(join(dir_root, "Run?")))
dir_resize = join(dir_root, 'resized')

for dir_run in list_dir_run:
    run = dir_run.split('/')[-1]
    dir_output = join(dir_resize, run)
    makedirs(dir_output, exist_ok=True)
    
    ## copy the log file
    shutil.copy2(join(dir_run, 'log.json'), join(dir_output, 'log.json'))

    ## resize image files
    list_fname = glob(join(dir_run, '*.png'))
    for fname in list_fname:
        img = Image.open(fname)
#         print(img.size)
        step = int(fname.split('/')[-1].split('.')[0])
        img_resized = img.resize((128,72))
        img_resized.save(join(dir_output, '%05d.png'%step))
