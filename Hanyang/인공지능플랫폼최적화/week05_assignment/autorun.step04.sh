#!/bin/zsh

root_dir=`pwd`
work_dir=$root_dir/Step_4
cd $work_dir

clang -emit-llvm -S Test.c -o Test.ll
foreach worker (InsertInst ReplaceInst)
	echo "## $worker ##"
	clang++ $worker.cpp -o $worker $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)
	./$worker Test.ll Test.$worker.ll
	
	clang ./Test.$worker.ll -o Test
	./Test
	echo ''
end
vimdiff ./*.ll

## Exercise 2-1
worker=$root_dir/sampark.step04_exercise2-1.ReplaceInst
clang++ $worker.cpp -o ReplaceInst_ex2-1 $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)
clang -emit-llvm -S Test.c -o Test.ll
./ReplaceInst_ex2-1 Test.ll Test.ex2-1.ll
vimdiff ./Test.ll ./Test.ex2-1.ll

clang ./Test.ex2-1.ll -o Test
./Test

## Exercise 2-2
 #clang -emit-llvm -S Test.c -o Test.ll
 #clang ./Test.ll -o Test
 #./Test
 #
 #clang++ InsertInst.cpp -o InsertInst $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)
 #./InsertInst Test.ll Test.Processed.ll
 #clang ./Test.Processed.ll -o Test
 #./Test

