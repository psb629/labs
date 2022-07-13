#!/bin/bash

for subj in `cat GLsublist`; do
/usr/local/bin/python3 onset2par.py ${subj}_MoveStop.txt
mv GLonset.par ~/Desktop/GL_FS/GLFS_data/$subj/fingers/001
done
