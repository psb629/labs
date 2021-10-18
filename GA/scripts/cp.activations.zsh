#!/bin/zsh

subjs=( 01 02 05 07 08 \
		11 12 13 14 15 \
		18 19 20 21 23 \
		26 27 28 29 30 \
		31 32 33 34 35 \
		36 37 38 42 44 )

layers=`seq -f "layer%02g" 1 13`

trials=`seq -f "trial%02g" 1 97`

foreach subj in $subjs
	echo "Copying data of Subject $subj"
	gg='GB'
	dir_to=~/vgg16/$subj
	if [ ! -d $dir_to ]; then
		mkdir -p -m 755 $dir_to
	fi
	dir_from=~/GoogleDrive/GA/results/activations/vgg16/$subj
	foreach run in 'r01' 'r02' 'r03'
		foreach trial in $trials
			foreach layer in $layers
				fname=$gg$subj.$run.$trial.$layer.nframe075.npy
				to=$dir_to/$fname
				if [ ! -e $to ]; then
					cp -n $dir_from/$fname $to
				fi
			end
		end
	end
end
