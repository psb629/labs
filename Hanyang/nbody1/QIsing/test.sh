#!/bin/bash
OUT=test.out
icpc test.cpp mt19937ar.o utils.o -lblas -llapack -o $OUT
echo " Execute $OUT"
./$OUT &
#./$OUT > 'printB12'.dat &
echo " Remove $OUT"
rm $OUT
