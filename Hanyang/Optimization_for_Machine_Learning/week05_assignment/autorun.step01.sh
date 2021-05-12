#!/bin/zsh

root_dir=`pwd`
work_dir=$root_dir/Step_1
 #output_dir=$work_dir/result
 #if [ ! -d $output_dir ]; then
 #	mkdir -p -m 755 $output_dir
 #fi
cd $work_dir

clang -emit-llvm -S HelloWorld.c -o HelloWorld.ll
clang -emit-llvm -c HelloWorld.c -o HelloWorld.bc

llvm-as HelloWorld.ll -o=HelloWorld.2.bc
llvm-dis HelloWorld.bc -o=HelloWorld.2.ll
vimdiff HelloWorld.ll HelloWorld.2.ll

llc HelloWorld.ll -o HelloWorld.s

clang++ ReadIR.cpp -o ReadIR $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)

./ReadIR HelloWorld.ll
./ReadIR HelloWorld.bc
