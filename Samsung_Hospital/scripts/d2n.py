import os
from glob import glob
from os.path import join, dirname
import nibabel as nib
import numpy as np
path_work = '/store4/ksbyeon/remove/SMC_alignmennt'

list_rest = glob(join(path_work, 'SMC??/*MRI'))
list_T1w = glob(join(path_work, 'SMC??/*T1'))



def dcm2nii(path_dcm, path_output):
	import pydicom
	data_base = os.path.basename(path_dcm)
	os.system('dcm2niix -o {}/ -f {} -z y {}'.format(path_output, data_base, path_dcm))
	os.system('chmod 777 -R {}'.format(path_output))

dcm2nii(list_rest[1], join(path_work, 'nifti'))
dcm2nii(list_T1w[1], join(path_work, 'nifti'))


