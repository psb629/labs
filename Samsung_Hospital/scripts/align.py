import os
from glob import glob
from os.path import join, dirname
import nibabel as nib
import numpy as np
path_work = '/store4/ksbyeon/remove/SMC_alignmennt/nifti'

list_rest = glob(join(path_work, 'SMC??_REST.nii.gz'))
list_T1w = glob(join(path_work, 'SMC??_T1w.nii.gz'))

idx = 0

rest = list_rest[idx]
T1w = list_T1w[idx]
sub_name = rest.split(os.sep)[-1].split('_')[0]

path_prep = join(dirname(rest), sub_name)
path_anat = join(path_prep, 'anat')
path_rest = join(path_prep, 'rest')

os.makedirs(path_prep, exist_ok=True)
os.makedirs(path_anat, exist_ok=True)
os.makedirs(path_rest, exist_ok=True)

########
# ANAT #
########
os.chdir(path_anat)
os.system('3dcopy {} orig.nii.gz'.format(T1w))
os.system('3dWarp -deoblique -prefix deoblique.nii.gz orig.nii.gz')
os.system('3dresample -orient RAI -prefix rai.nii.gz -inset deoblique.nii.gz')
os.system('3dUnifize -input rai.nii.gz -prefix unifize.nii.gz -clfrac 0.5')
os.system('3dSkullStrip -orig_vol -input unifize.nii.gz -prefix ss.nii.gz')
os.system('3dcopy ss.nii.gz ../rest/ss.nii.gz')

########
# REST #
########
os.chdir(path_rest)
os.system('3dcopy {} orig.nii.gz'.format(rest))
os.system('3dresample -orient RAI -prefix rai.nii.gz -inset orig.nii.gz')


#  Check Severe motion
os.system(
	'fsl_motion_outliers -i rai.nii.gz -o mot_confound '
	'-s FD_metric -p FD_metric_plot --fd --thresh=0.5 -t ./')
fd_met = np.loadtxt('FD_metric')

severe_mot_vol = np.where(fd_met > 0.5)[0]
if len(severe_mot_vol):
	print('{} Volumes should be removed'.format(len(severe_mot_vol)))
else:
	print('No problem')

# Motion Correction
nv = nib.load('rai.nii.gz').header['dim'][4]
SBRef = int(nv//2)
os.system('fslroi rai SBRef {} {}'.format(SBRef, 1)) # for vis check
os.system(
	'mcflirt -in rai.nii.gz -out mc '
	'-mats -plots -refvol {} -rmsrel -rmsabs'.format(SBRef))

# Skull strip
os.system('fslmaths mc -Tmean Tmean') # mean across time
os.system('bet2 Tmean bin -f 0.3 -n -m') # skull binary image
os.system('fslmaths mc -mas bin_mask bet') # masking
os.system('fslstats bet -p 2 -p 98 > thres_val.txt')
thres = np.loadtxt('thres_val.txt')[1] / 10
os.system('fslmaths bet -thr {} -Tmin -bin bin_mask -odt char'.format(thres))
os.system('fslstats mc -k bin_mask -p 50')
os.system('fslmaths bin_mask -dilF bet')
os.system('fslmaths mc -mas bet thr')

# Intensity normalization
os.system('fslmaths thr -inm 10000 norm')
os.system('fslmaths norm filt')

TR = nib.load('rai.nii.gz').header['pixdim'][4]
os.system('fslhd -x filt | sed "s/ dt=.*/ dt = "{:.3f}"/g" > tmpHeader'.format(TR))
os.system('fslcreatehd tmpHeader filt')
os.system('fslmaths filt -Tmean mean_filt')
os.system('fslroi filt SBRef_filt {} {}'.format(SBRef, 1))

# Initial registration

os.system(
	'flirt -ref SBRef_filt -in ss -out HR2Func_ref '
	'-omat HR2Func.mat -cost mutualinfo -dof 12 '
	'-searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear')
os.system('convert_xfm -inverse -omat Func2HR.mat HR2Func.mat'
os.system(
	'flirt -applyxfm -init Func2HR.mat -in filt '
	'-ref ss -out Func2HR -interp trilinear')



os.system(
	'flirt -ref ss.nii.gz -in SBRef -out Func2HR_ref '
	'-omat Func2HR.mat -cost mutualinfo -dof 12 '
	'-searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear')
os.system(
	'flirt -applyxfm -init Func2HR.mat -in filt '
	'-ref ss -out Func2HR -interp trilinear')




# ICA
print('ICA-FIX...')
os.makedirs('ICAFIX')
os.makedirs('ICAFIX/mc')
os.makedirs('ICAFIX/reg')

shutil.copy2('filt.nii.gz', 'ICAFIX/filt.nii.gz')
shutil.copy2('mc.par', 'ICAFIX/mc/prefilt_mcf.par')
shutil.copy2('mean_filt.nii.gz', 'ICAFIX/mean_filt.nii.gz')
os.system('fslmaths ICAFIX/mean_filt -bin ICAFIX/mask')

shutil.copy2('mean_filt.nii.gz', 'ICAFIX/reg/example_func.nii.gz')
shutil.copy2('ss.nii.gz', 'ICAFIX/reg/highres.nii.gz')
shutil.copy2('HR2Func.mat', 'ICAFIX/reg/highres2example_func.mat')

os.system(
	'melodic -i ICAFIX/filt -o ICAFIX/filt.ica ' +
	'-v --nobet --bgthreshold=3 --tr={0:.3f} --report -d {1} --mmthresh=0.5 --Ostats'.format(TR, 0))

# Extract features (for later training and/or classifying)
os.system('fix -f ICAFIX')
# classify ICA components using a specific training dataset
fix_train = '/store4/ksbyeon/ETC/preprocessing/fix1.065/training_files/Standard.RData'
os.system('fix -c ICAFIX {} 20'.format(fix_train))
# apply cleanup, using artefacts listed in the .txt file
os.system('fix -a ICAFIX/fix4melview_{}_thr20.txt -m -h 0 -A'.format(fix_train.split('/')[-1].split('.')[0]))
shutil.copy2('ICAFIX/filt_clean.nii.gz', 'filt_clean.nii.gz')

# Temporal filtering
os.system('3dFourier -lowpass 0.08 -highpass 0.009 -prefix bpf.nii.gz -retrend filt_clean.nii.gz')

# Spatial filtering
# FWHM = np.ceil(2 * float(os.popen('3dinfo -adi rai.nii.gz').read()))
FWHM = 5
os.system('3dmerge -quiet -1blur_fwhm {0} -doall -prefix smt.nii.gz bpf.nii.gz'.format(FWHM))
os.system('chmod 777 -R ./')