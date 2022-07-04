https://github.com/vsoch/TtoZ

#installation
`pip install TtoZ`

- Error 발생
`~/anaconda3/envs/GA/lib/python3.9/site-packages/TtoZ/scripts.py`
위의 31번째 줄 print 부분에서 에러가 발생함. print -> print() 꼴로 변경해주자.

#Usage
```
usage: TtoZ [-h] --t_stat_map T_STAT_MAP --dof DOF [--output_nii OUTPUT_NII]

  Convert a whole brain T score map to a Z score map without loss of precision
  for strongly positive and negative values.

  optional arguments:
   -h, --help            show this help message and exit
    --t_stat_map T_STAT_MAP
                          T-score statistical map in the form of a 3D NIFTI file
                          (.nii or .nii.gz).
    --dof DOF             Degrees of freedom (eg. for a two-sample T-test:
                          number of subjects in group - 2)
    --output_nii OUTPUT_NII
                          The name for the output Z-Score Map.
```
- dof 는 3dinfo -verb 명령어를 사용하여 `statcode = fitt; statpar = ???` 의 "???" 부분을 읽으면 된다.

#Example
`TtoZ --t_stat_map=t_stat_map.nii.gz --dof=484 --output_nii=z_score_map.nii`
