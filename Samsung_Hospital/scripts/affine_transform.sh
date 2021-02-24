#!/bin/tcsh

set subj = S23

set root_dir = /Users/clmnlab/Desktop
set fmri_dir = $root_dir/fmri_data
set preproc_dir = $fmri_dir/preproc_data
set data_dir = $preproc_dir/$subj/preprocessed

set affine_matrix = $data_dir/deoblique.aff.2D
# ===================================================
## A coordinate of the target
set vec_r = (10 -22 -40)
# ===================================================
## calculation
set vec_r = ($vec_r 1)
set vec_rp = ()
foreach ll (`count -digits 2 2 4`)
	set line = `head -${ll} $affine_matrix |tail -1`
	set sum = 0
	foreach xx (`count -digits 2 1 4`)
		set temp = `python -c "print($line[$xx]*$vec_r[$xx])"`
		set sum = `python -c "print($temp+$sum)"`
	end
	set vec_rp = ($vec_rp $sum)
end
# ===================================================
## result
echo $vec_rp
