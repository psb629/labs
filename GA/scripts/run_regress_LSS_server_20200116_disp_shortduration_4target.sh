#!/bin/tcsh

# set subjlist = (GA01 GA02 GA05 GA07 GA08 GA11 GA12 GA13 GA14 GA15 GA18 GA19 GA20 GA21 GA23 GA26 GA27 GA28 GA29 GA30 GA31 GA32 GA33 GA34 GA35 GA36 GA37 GA38 GA42 GA44)
set subjlist = (GB01 GB02 GB05 GB07 GB08 GB11 GB12 GB13 GB14 GB15 GB18 GB19 GB20 GB21 GB23 GB26 GB27 GB28 GB29 GB30 GB31 GB32 GB33 GB34 GB35 GB36 GB37 GB38 GB42 GB44)
# set subjlist = (GB01 GB02 GB05 GB07 GB08 GB11 GB12 GB13 GB14 GB15 GB18 GB19 GB20 GB21 GB23 GB26 GB27 GB28 GB30 GB31 GB32 GB33 GB34 GB35 GB36 GB37 GB38 GB42)
# set subjlist = (GB29)
# set subjlist = (GC01 GC02 GC05 GC07 GC08 GC11 GC12 GC14 GC15 GC19 GC20 GC23 GC26 GC29 GC30 GC31 GC32 GC33 GC34 GC35)
# set subjlist = (GA44 GB44)
# set runs = (`count -digits 2 1 3`)
# set runs = (`count -digits 2 1 6`)
# set runs = (`count -digits 2 1 3`)
set basis = 'BLOCK(0.46,1)'
# set basis = 'BLOCK(5,1)'

set group = GB

foreach subj ($subjlist)
    set data_dir = /clmnlab/GA/fmri_data/preproc_data/$subj
    set subj_GA = `echo $subj | sed 's/GB/GA/g'`
    set reg_dir = /clmnlab/GA/fmri_data/regressors/reg_4targets/$subj_GA
    set reg_dir_disp = /clmnlab/GA/regressors/reg_onset_displacement/AM1_reg_disp_convolve
    set output_dir = /clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data_4target/run1to3

    if (! -d $output_dir) then
        mkdir $output_dir
    else
        echo "output dir ${output_dir} already exists"
    endif

    cat ${reg_dir_disp}/AM1.disp.ideal.${subj}.r01.xmat.1D \
        ${reg_dir_disp}/AM1.disp.ideal.${subj}.r02.xmat.1D \
        ${reg_dir_disp}/AM1.disp.ideal.${subj}.r03.xmat.1D \
        > ${reg_dir_disp}/AM1.disp.ideal.${subj}.run1to3.xmat.1D

    cd $data_dir
    3dDeconvolve -input $data_dir/pb02.$subj.r01.volreg+tlrc.HEAD     \
        $data_dir/pb02.$subj.r02.volreg+tlrc.HEAD     \
        $data_dir/pb02.$subj.r03.volreg+tlrc.HEAD     \
        -censor $data_dir/motion_${subj}.censor_run1to3.1D          \
        -mask $data_dir/full_mask.$subj+tlrc                               \
        -local_times                                                       \
        -polort A -float                                                   \
        -num_stimts 11                                                      \
        -stim_times 1 $reg_dir/${subj_GA}_${group}_onset_prac_target1.txt $basis -stim_label 1 beta_target1   \
        -stim_times 2 $reg_dir/${subj_GA}_${group}_onset_prac_target5.txt $basis -stim_label 2 beta_target5   \
        -stim_times 3 $reg_dir/${subj_GA}_${group}_onset_prac_target21.txt $basis -stim_label 3 beta_target21   \
        -stim_times 4 $reg_dir/${subj_GA}_${group}_onset_prac_target25.txt $basis -stim_label 4 beta_target25   \
        -stim_file 5 motion_demean.$subj.r$run.1D'[0]' -stim_base 5 -stim_label 5 roll   \
        -stim_file 6 motion_demean.$subj.r$run.1D'[1]' -stim_base 6 -stim_label 6 pitch  \
        -stim_file 7 motion_demean.$subj.r$run.1D'[2]' -stim_base 7 -stim_label 7 yaw    \
        -stim_file 8 motion_demean.$subj.r$run.1D'[3]' -stim_base 8 -stim_label 8 dS     \
        -stim_file 9 motion_demean.$subj.r$run.1D'[4]' -stim_base 9 -stim_label 9 dL     \
        -stim_file 10 motion_demean.$subj.r$run.1D'[5]' -stim_base 10 -stim_label 10 dP     \
        -stim_file 11 ${reg_dir_disp}/AM1.disp.ideal.${subj}.run1to3.xmat.1D'[5]' -stim_base 11 -stim_label 11 MO     \
        -fout -tout \
        -x1D $output_dir/X.xmat.MO.shortdur.4target.$subj.run1to3.1D           \
        -xjpeg $output_dir/X.xmat.MO.shortdur.4target.$subj.run1to3.jpg           \
        -x1D_uncensored $output_dir/X.nocensor.xmat.MO.shortdur.4target.$subj.run1to3.1D \
        -errts $output_dir/errts.MO.shortdur.4target.$subj.run1to3 \
        -bucket $output_dir/stats.MO.shortdur.4target.$subj.run1to3

    # 3dLSS  -verb -input $data_dir/pb02.$subj.r$run.volreg+tlrc.HEAD     \
    #     -prefix $output_dir/betasLSS.MO.shortdur.4target.$subj.r$run       \
    #     -matrix $output_dir/X.xmatLSS.MO.shortdur.4target.$subj.r$run.1D   \
    #     -mask $data_dir/full_mask.$subj+tlrc         \
    #     -save1D $output_dir/X.betas.LSS.MO.shortdur.4target.$subj.r$run
end
