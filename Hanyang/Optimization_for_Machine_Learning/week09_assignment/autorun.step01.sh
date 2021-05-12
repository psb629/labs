#!/bin/zsh

root_dir=/Users/clmnlab/Desktop/aiplatform_HW2_for_students_updated
step_dir=$root_dir/HW_1
source_file=$step_dir/opencl_host_HW1.c
kernel=vector_add_kernel.cl
 #modified=$step_dir/modified.opencl_host_HW1.c
output_file=a.exe

cd $step_dir
 #sed -e s:$kernel:$step_dir/$kernel:g $source_file >$modified
 #gcc -framework OpenCL $modified -o $output_file
gcc $source_file -framework OpenCL -o $output_file -I $step_dir
./$output_file
