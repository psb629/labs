#!/bin/bash
OUT=a.out
#echo " Transform lecture.c to lecture.o"
#g++ -c lecture.c
echo " Make a.out file"
g++ lecture.c mt19937ar.o hk.o nz.o -o $OUT
echo " Execute a.out file"
#./$OUT &
./$OUT > printf.dat &
echo " Remove a.out file"
rm $OUT
