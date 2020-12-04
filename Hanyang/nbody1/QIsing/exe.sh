#!/bin/bash
IN=Qising_ver3
OUT=chi10.out
#OUT=a.out
#echo " Transform $IN.cpp to $IN.o"
#icpc -c $IN.cpp
#echo " Make OUT file"
#icpc $IN.o mt19937ar.o utils.o -lblas -llapack -o $OUT
icpc $IN.cpp mt19937ar.o utils.o -lblas -llapack -o $OUT
echo " Execute $OUT"
#./$OUT & 
./$OUT > 'm_chi10'.dat &
echo " Remove $OUT"
rm $OUT
