#!/bin/tcsh

# set subjlist = (GA01 GA02 GA05 GA07 GA08 GA11 GA12 GA13 GA14 GA15 GA18 GA19 GA20 GA21 GA23 GA26 GA27 GA28 GA29 GA30 GA31 GA32 GA33 GA34 GA35 GA36 GA37 GA38 GA42)
# set subjlist = (GB01 GB02 GB05 GB07 GB08 GB11 GB12 GB13 GB14 GB15 GB18 GB19 GB20 GB21 GB23 GB26 GB27 GB28 GB30 GB31 GB32 GB33 GB34 GB35 GB36 GB37 GB38 GB42)
# set subjlist = (GB29)
set subjlist = (GC01 GC02 GC05 GC07 GC08 GC11 GC12 GC14 GC15 GC19 GC20 GC23 GC26 GC29 GC30 GC31 GC32 GC33 GC34 GC35)
# set subjlist = (GA02 GA05 GA07 GA08 GA11 GA12 GA13 GA14 GA15 GA18 GA19 GA20 GA21 GA23 GA26 GA27 GA28 GA29 GA30 GA31 GA32 GA33 GA34 GA35 GA36 GA37 GA38 GA42 GB01 GB02 GB05 GB07 GB08 GB11 GB12 GB13 GB14 GB15 GB18 GB19 GB20 GB21 GB23 GB26 GB27 GB28 GB30 GB31 GB32 GB33 GB34 GB35 GB36 GB37 GB38 GB42)
set runs = (`count -digits 2 1 7`)
# set runs = (`count -digits 2 1 6`)
# set runs = (`count -digits 2 1 3`)
set basis = 'BLOCK(0.46,1)'
# set basis = 'BLOCK(5,1)'

foreach subj ($subjlist)
    set data_dir = /clmnlab/GA/fmri_data/preproc_data/$subj
    set reg_dir = /clmnlab/GA/regressors/LSS_reg_center/$subj
    set reg_dir_disp = /clmnlab/GA/regressors/reg_onset_displacement/AM1_reg_disp_convolve
    set output_dir = /clmnlab/GA/MVPA/LSS_pb02_MO_short_duration/data_201910

    if (! -d $output_dir) then
        mkdir $output_dir
    else
        echo "output dir ${output_dir} already exists"
    endif

    cd $data_dir
    foreach run ($runs)
        3dDeconvolve -input $data_dir/pb02.$subj.r$run.volreg+tlrc.HEAD     \
            -censor $data_dir/motion_{$subj}.r{$run}_censor.1D          \
            -mask $data_dir/full_mask.$subj+tlrc                               \
            -local_times                                                       \
            -polort A -float                                                   \
            -num_stimts 8                                                      \
            -stim_times_IM 1 $reg_dir/{$subj}_onsettime.r$run.txt $basis    \
            -stim_label 1 beta                                                     \
            -stim_file 2 motion_demean.$subj.r$run.1D'[0]' -stim_base 2 -stim_label 2 roll   \
            -stim_file 3 motion_demean.$subj.r$run.1D'[1]' -stim_base 3 -stim_label 3 pitch  \
            -stim_file 4 motion_demean.$subj.r$run.1D'[2]' -stim_base 4 -stim_label 4 yaw    \
            -stim_file 5 motion_demean.$subj.r$run.1D'[3]' -stim_base 5 -stim_label 5 dS     \
            -stim_file 6 motion_demean.$subj.r$run.1D'[4]' -stim_base 6 -stim_label 6 dL     \
            -stim_file 7 motion_demean.$subj.r$run.1D'[5]' -stim_base 7 -stim_label 7 dP     \
            -stim_file 8 {$reg_dir_disp}/AM1.disp.ideal.{$subj}.r{$run}.xmat.1D'[5]' -stim_base 8 -stim_label 8 MO     \
            -x1D_stop -x1D $output_dir/X.xmatLSS.MO.shortdur.$subj.r$run.1D           \
            -x1D_uncensored $output_dir/X.nocensor.xmatLSS.MO.shortdur.$subj.r$run.1D
        #
        # 3dLSS  -verb -input $data_dir/pb02.$subj.r$run.volreg+tlrc.HEAD     \
        #     -prefix $output_dir/betasLSS.MO.shortdur.$subj.r$run       \
        #     -matrix $output_dir/X.xmatLSS.MO.shortdur.$subj.r$run.1D   \
        #     -mask $data_dir/full_mask.$subj+tlrc         \
        #     -save1D $output_dir/X.betas.LSS.MO.shortdur.$subj.r$run
    end
end
