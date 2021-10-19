#!/bin/zsh

list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
list_layer=(`seq -f "layer%02g" 1 13`)
list_run=(`seq -f "r%02g" 1 3`)
# ================================================
dir_root=/home/sungbeenpark/activations
dir_eval=$dir_root/vgg16/pca/eval
# ================================================
roi='fullmask'
dir_fin=$dir_eval/$roi
 #dir_fin=$dir_eval/tmp
if [ ! -d $dir_fin ]; then
	mkdir -p -m 755 $dir_fin
fi
# ================================================
gg='GB'

foreach run in $list_run
	foreach layer in $list_layer
		list=()
		fin=score.$run.$roi.$layer.nii
		foreach nn in $list_nn
			datum=score.$run.$roi.$layer.$gg$nn.nii
			list+=($dir_eval/$nn/$datum)
		end
		3dMean -prefix $dir_fin/$fin $list
	end
end

 #foreach nn in $list_nn
 #	foreach layer in $list_layer
 #		list=()
 #		fin=score.$nn.late_practice.$roi.$layer.nii
 #		foreach run in $list_run
 #			datum=score.$run.$roi.$layer.$gg$nn.nii
 #			list+=($dir_eval/$nn/$datum)
 #		end
 #		3dMean -prefix $dir_fin/$fin $list
 #	end
 #end
