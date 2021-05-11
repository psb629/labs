#!/bin/zsh

root_dir=`pwd`
work_dir=$root_dir/Step_2
cd $work_dir

clang++ PrintInst.cpp -o PrintInst $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)

clang -emit-llvm -S Test.c -o Test.ll

./PrintInst Test.ll
