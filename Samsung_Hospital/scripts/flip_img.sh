#!/bin/zsh

root_dir=~/Downloads

foreach subj (S27 S28)
	foreach axis (s c a)
		img_file=$root_dir/${subj}_${axis}.png

		## Flip a image horizontally
		sips -f horizontal $img_file
	end
end
