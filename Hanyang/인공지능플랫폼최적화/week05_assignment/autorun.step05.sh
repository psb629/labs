#!/bin/zsh

root_dir=`pwd`
work_dir=$root_dir/Step_5
cd $work_dir

clang++ MoveInst.cpp -o MoveInst $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)
clang -emit-llvm -S Test.c -o Test.ll
./MoveInst ./Test.ll ./Test.Processed.ll
vimdiff ./Test.ll ./Test.Processed.ll

clang Test.ll -o Test
clang ./Test.Processed.ll -o Test.Processed
echo "./Test"
./Test
echo "./Test.Processed"
./Test.Processed
