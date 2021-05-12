#!/bin/zsh

root_dir=`pwd`
work_dir=$root_dir/Step_3
cd $work_dir

worker=CountInst
echo "## $worker ##"
clang++ $worker.cpp -o $worker $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)

echo "clang -emit-llvm -S Test.c -o Test.ll"
clang -emit-llvm -S Test.c -o Test.ll
./$worker ./Test.ll

echo "clang -O3 -emit-llvm -S Test.c -o Test.ll"
clang -O3 -emit-llvm -S Test.c -o Test.ll
./$worker ./Test.ll

echo ''

## Exercises
foreach worker ($root_dir/sampark.step03_exercise1-1.CountInst)
	echo "## $worker ##"
	clang++ $worker.cpp -o CountInst_ex1-1 $(llvm-config --cxxflags --ldflags --system-libs --libs mcjit irreader)
	
	echo "clang -emit-llvm -S Test.c -o Test.ll"
	clang -emit-llvm -S Test.c -o Test.ll
	./CountInst_ex1-1 ./Test.ll
	
	echo "clang -O3 -emit-llvm -S Test.c -o Test.ll"
	clang -O3 -emit-llvm -S Test.c -o Test.ll
	./CountInst_ex1-1 ./Test.ll
	
	echo ''
end
