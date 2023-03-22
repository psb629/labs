#!/usr/bin/env python

import sys
import os
from os.path import join, exists
from glob import glob
import numpy as np
## ==================================================== ##
## arg #1: An input text file
if ('-i' in sys.argv):
    idx = sys.argv.index('-i')
elif ('--input' in sys.argv):
    idx = sys.argv.index('--input')
input_ = sys.argv[idx+1]

## arg #2: An ouput text file
if ('-o' in sys.argv):
    idx = sys.argv.index('-o')
elif ('--output' in sys.argv):
    idx = sys.argv.index('--output')
output_ = sys.argv[idx+1]

## arg #3: The range of lines to extract
if ('-a' in sys.argv):
    idx = sys.argv.index('-a')
a_ = int(sys.argv[idx+1])
if ('-b' in sys.argv):
    idx = sys.argv.index('-b')
b_ = int(sys.argv[idx+1])
## ==================================================== ##
## To get the current working directory
cwd = os.getcwd()
## ==================================================== ##
dir_parent = input_.split('/')[0]
iname = input_.split('/')[-1]
if dir_parent=='.':
    input_ = join(cwd, iname)
assert exists(input_)
## ==================================================== ##
dir_parent = output_.split('/')[0]
oname = output_.split('/')[-1]
if dir_parent=='.':
    output_ = join(cwd, oname)
assert not exists(output_)
## ==================================================== ##
input_ = np.loadtxt(
    input_
    , dtype=str
    , comments='#'
)
## ==================================================== ##
assert a_<=b_
assert b_<=input_.shape[0]
## ==================================================== ##
np.savetxt(
    output_, input_[a_-1:b_]
    , fmt='%s'
    , delimiter=' '
    , newline='\n'
)
## ==================================================== ##
