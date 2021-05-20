#!/bin/zsh

nn_list=( 01 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ==================================================================
x=1
let x+=1
echo 1:$x
((x+=1))
echo 2:$x
x=$[$x+1]
echo 3:$x
x=`expr $x + 1`
echo 4:$x
x=`echo "$x+1"|bc`
echo 5:$x
x=3.14
x=`echo "scale=2;$x*2"|bc`
echo 6:$x

foreach x (1 2)
	if [ $x -eq 1 ]; then
		echo "$x -eq 1 : true"
	 #elif [ ! $x -eq 1 ]; then
	 #	echo "false"
	 else;
	 	echo "$x -eq 1 : else"
	fi
end

foreach x (`count -digits 2 0 3`)
	if [ $x -eq "0" ]; then
		echo "$x finded!"
	else;
		echo "$x"
	fi
end
