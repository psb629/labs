#!/bin/tcsh

## @auto_tlrc:
## The script will output the final transform in a 1D file with the
## extension Xat.1D, say THAT_NAME.1D
## Call this transform Mt and let Xt and Xo be the 4x1 column vectors
## coordinates of the same voxel in standard (t) and original (o)
## space, respectively. The transform is such that Xo = Mt Xt 
## You can use this transform to manually warp a volume in orig

# the user may specify a single subject to run with
 #if ( $#argv > 0 ) then
 #    set subj = $argv[1]
 #else
 #    set subj = "invalid"
 #endif

set subj = "Jihoon_Kim"
set abbrev = "KJH"
echo "#################"
echo "$subj"
echo "#################"

set root_dir = /home/sungbeenpark/Happy_Mind
set fmri_dir = $root_dir
set preproc_dir = $fmri_dir/preproc_data
set data_dir = $preproc_dir/$subj

## The final transform:
set affine_matrix = $data_dir/warp.$abbrev.anat.Xat.1D
#set affine_matrix = $data_dir/deoblique.$subj.aff.2D
echo "Mt="
cat $affine_matrix
# ===================================================
## A target coordinate of Dementia  (NOTE, the order would be RAI=DICOM)
set At = (50 67 33)
## A target coordinate of Depression (NOTE, the order would be RAI=DICOM)
set Bt = (41 -43 27)
# ===================================================
## Affine transformation
set At = ($At 1)
set Bt = ($Bt 1)
set vec_a = ()
set vec_b = ()
set sign = (-1 -1 1)
foreach ll (`count -digits 2 1 3`)
	set line = `head -${ll} $affine_matrix |tail -1`
	set sum_a = 0
	set sum_b = 0
	foreach xx (`count -digits 2 1 4`)
		set temp = `python -c "print($line[$xx]*$At[$xx])"`
		set sum_a = `python -c "print('%.4f'%($temp+$sum_a))"`
		set temp = `python -c "print($line[$xx]*$Bt[$xx])"`
		set sum_b = `python -c "print('%.4f'%($temp+$sum_b))"`
	end
	## convert the result to LPI
	set sum_a = `python -c "print('%.4f'%($sum_a*$sign[$ll]))"`
	set sum_b = `python -c "print('%.4f'%($sum_b*$sign[$ll]))"`
	set vec_a = ($vec_a $sum_a)
	set vec_b = ($vec_b $sum_b)
end
# ===================================================
## result
echo " Dementia"
echo " $vec_a"
echo " Depression"
echo " $vec_b"
