#!/bin/zsh

list_id=( 'GA' 'GB' )
list_nn=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
list_layer=()
foreach i in `seq -f "%02g" 1 13`
	list_layer=($list_layer 'layer'$i)
end
echo $list_layer

dir_data=~/GoogleDrive/GA/results/activations/vgg16/pca/eval
dir_output=$dir_data

roi='fullmask'
id='GB'
nn=01
foreach layer in $list_layer
	pname=score.$roi.$layer.$id$nn.nii
	3dMean -prefix $dir_output/$pname $dir_data/score.r*.$roi.$layer.$id$nn.nii
end
