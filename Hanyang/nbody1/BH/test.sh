#!/bin/bash
icpc test.cpp mt19937ar.o utils.o -lblas -llapack
echo " Execute test.sh"
./a.out &
echo " Remove a.out"
rm a.out
