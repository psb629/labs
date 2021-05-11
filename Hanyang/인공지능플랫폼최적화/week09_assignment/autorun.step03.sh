root_dir=`pwd`
step_dir=$root_dir/HW_3
source=opencl_host_HW3.c
kernel=matmul_HW3.cl
modified=opencl_host_HW3.cpp
filled=matmul_HW3.modified.cl
output_file=a.exe

cd $step_dir
## kernel, fill이 두번 들어가는 행 밑($'\n')에 Csub+=A[tidx\*N+k]\*B[k\*N+tidy]; 추가(a\) 후 편집(-i)
## Note, $'__' : quoting syntax for inserting C-style escapes
sed -e '/fill.*fill/a\'$'\n\t\t\t''Csub+=A[tidx\*N+k]\*B[k\*N+tidy];'$'\n' $filled >temp.cl
## kernel, fill이 들어가고, Csub이 뒤에 나오는 행 밑($'\n')에 C[tidx\*N+tidy]=Csub; 추가(a\) 후 편집(-i)
sed	-e '/fill.*Csub/a\'$'\n\t\t''C[tidx\*N+tidy]=Csub;'$'\n' temp.cl >$filled
## fill[빈칸]here 이 들어간 행 삭제
sed '/fill[[:space:]]here/d' $? > $?

rm ./temp.cl

## opencl_host_HW3, 커널파일이 바뀌었으므로 바뀐 커널로 불러오기. 
sed -e "s:$kernel:$filled:g" $source >$modified
## C++ compiler
g++ $modified -framework OpenCL -o $output_file #-I$root_dir/common -I$step_dir
## run
./$output_file
