#!/bin/tcsh

set subj = S22

set root_dir = /Users/clmn/Desktop/Samsung_Hospital
set fmri_dir = $root_dir/fmri_data
set preproc_dir = $fmri_dir/preproc_data
set data_dir = $preproc_dir/$subj/preprocessed

set affine_matrix = $data_dir/deoblique.$subj.aff.2D
cat $affine_matrix
# ===================================================
## A coordinate of the target
set target = (-49.154 -63.342 22.470)
set hippo = (-29.333 -17.344 -3.750)
set vec_r = (-29.333 -17.344 -3.750)
# ===================================================
## Affine transformation
set vec_r = ($vec_r 1)
set vec_rp = ()
foreach ll (`count -digits 2 2 4`)
	set line = `head -${ll} $affine_matrix |tail -1`
	set sum = 0
	foreach xx (`count -digits 2 1 4`)
		set temp = `python -c "print($line[$xx]*$vec_r[$xx])"`
		set sum = `python -c "print('%.4f'%($temp+$sum))"`
	end
	set vec_rp = ($vec_rp $sum)
end
# ===================================================
## result
echo $vec_rp
