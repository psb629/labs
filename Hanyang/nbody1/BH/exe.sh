#!/bin/bash
IN=BH_ver3.cpp
OUT=chi18_2360.out
echo " Make OUT file"
icpc $IN mt19937ar.o utils.o -lblas -llapack -o $OUT
echo " Execute $OUT"
./$OUT &
#./$OUT > 'printf'.dat &
echo " Remove $OUT"
rm $OUT
