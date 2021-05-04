#!/bin/tcsh

set list = (a b c d e)
count -digits 2 1 4 1
echo $list[2]

set coord = orig
if ($coord == tlrc) then
	echo "$coord(tlrc)"
else if ($coord == orig) then
	echo "$coord(orig)"
else
	echo "None"
endif
