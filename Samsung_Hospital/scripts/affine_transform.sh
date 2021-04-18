#!/bin/tcsh

## @auto_tlrc:
## The script will output the final transform in a 1D file with the
## extension Xat.1D, say THAT_NAME.1D
## Call this transform Mt and let Xt and Xo be the 4x1 column vectors
## coordinates of the same voxel in standard (t) and original (o)
## space, respectively. The transform is such that Xo = Mt Xt 
## You can use this transform to manually warp a volume in orig

set subj = S24

set root_dir = /Volumes/T7SSD1/samsung_hospital
set fmri_dir = $root_dir/fmri_data
set preproc_dir = $fmri_dir/preproc_data
set data_dir = $preproc_dir/$subj/preprocessed

## The final transform:
set affine_matrix = $data_dir/warp.$subj.anat.Xat.1D
#set affine_matrix = $data_dir/deoblique.$subj.aff.2D
echo "Mt="
cat $affine_matrix
# ===================================================
## A coordinate of the target (NOTE, the order would be RAI=DICOM)
set Xo = (18.099 19.609 6.318)
set Xt = (27 29 -12)
# ===================================================
## Affine transformation
set Xt = ($Xt 1)
set vec_r = ()
foreach ll (`count -digits 2 1 3`)
	set line = `head -${ll} $affine_matrix |tail -1`
	set sum = 0
	foreach xx (`count -digits 2 1 4`)
		set temp = `python -c "print($line[$xx]*$Xt[$xx])"`
		set sum = `python -c "print('%.4f'%($temp+$sum))"`
	end
	set vec_r = ($vec_r $sum)
end
# ===================================================
## result
echo "Xt="
echo $Xt
echo "Mt*Xt="
echo $vec_r
echo "Xo="
echo $Xo
