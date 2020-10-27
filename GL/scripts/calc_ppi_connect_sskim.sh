#!/bin/tcsh
\#set rootdir = /projects/b1033/dervish_moto
set rootdir = /Users/sskim/Documents/Research/AFNI/MOTO
set datadir = /Volumes/clmnlab/DM/DATA
set maskdir = $rootdir/backup/masks
set masklist = (vmPFC_r5mm Rhipp_r5mm Lhipp_r5mm)
set subjlist = DM01
set subjlist = (DM01 DM02 DM03 DM04 DM05 DM06 DM07 DM08 DM10 DM11 DM12 DM14 DM15 DM16 DM17 DM18 DM19 DM22 DM23 DM25 DM26 DM29 DM30)
set subjlist = (DM04 DM05 DM06 DM07 DM08 DM10 DM11 DM12 DM14 DM15 DM16 DM17 DM18 DM19 DM22 DM23 DM25 DM26 DM29 DM30)

#set subjlist = DM10
set runlist = `count -digit 2 1 3`
set TR = 2
foreach subj ($subjlist)
#        set workdir = $rootdir/backup
         set workdir = $datadir/$subj	
        foreach mask ($masklist)
                foreach run ($runlist)
                        3dmaskave -mask $maskdir/mask.{$mask}+tlrc -quiet $workdir/pb04.$subj.r{$run}.scale+tlrc  > $rootdir/text_data/ppi_seed.$subj.r{$run}.$mask.1D
                        3dDetrend -polort 5 -prefix $rootdir/text_data/ppi_seedR.$subj.r{$run}.$mask.1D $rootdir/text_data/ppi_seed.$subj.r{$run}.$mask.1D\'
                        1dtranspose $rootdir/text_data/ppi_seedR.$subj.r{$run}.$mask.1D $rootdir/text_data/ppi_seed_ts.$subj.r{$run}.$mask.1D
                        waver -dt $TR -GAM -inline 1@1 > $rootdir/text_data/GammaHR.1D
                        3dTfitter -RHS $rootdir/text_data/ppi_seed_ts.$subj.r{$run}.$mask.1D -FALTUNG $rootdir/text_data/GammaHR.1D $rootdir/text_data/ppi_seed_neur.$subj.r${run}.$mask.temp1.1D 012 0
			1d_tool.py -infile $rootdir/text_data/ppi_seed_neur.$subj.r${run}.$mask.temp1.1D -write $rootdir/text_data/ppi_seed_neur.$subj.r${run}.$mask.temp2.1D
			1dtranspose $rootdir/text_data/ppi_seed_neur.$subj.r${run}.$mask.temp2.1D $rootdir/text_data/ppi_seed_neur.$subj.r${run}.$mask.1D
			rm $rootdir/text_data/ppi_seed_neur.$subj.r${run}.$mask.temp?.1D
                end
                cat $rootdir/text_data/ppi_seed_neur.$subj.r*.$mask.1D > $rootdir/text_data/ppi_seed_neur.$subj.$mask.1D
                cat $rootdir/text_data/ppi_seed_ts.$subj.r*.$mask.1D > $rootdir/text_data/ppi_seed_ts.$subj.$mask.1D
                        1deval -a $rootdir/text_data/ppi_seed_neur.$subj.$mask.1D -b $rootdir/cond_binary/{$subj}_binary_pri.txt\'                                \
                        -expr 'a*b' > $rootdir/text_data/Inter_neur.$subj.primacy.$mask.1D

                        1deval -a $rootdir/text_data/ppi_seed_neur.$subj.$mask.1D -b $rootdir/cond_binary/{$subj}_binary_ctl.txt\'                                \
                        -expr 'a*b' > $rootdir/text_data/Inter_neur.$subj.ctl.$mask.1D

                        1deval -a $rootdir/text_data/ppi_seed_neur.$subj.$mask.1D -b $rootdir/cond_binary/{$subj}_binary_fb.txt\'                                \
                        -expr 'a*b' > $rootdir/text_data/Inter_neur.$subj.fb.$mask.1D

                        1deval -a $rootdir/text_data/ppi_seed_neur.$subj.$mask.1D -b $rootdir/cond_binary/{$subj}_binary_nfb.txt\'                                \
                        -expr 'a*b' > $rootdir/text_data/Inter_neur.$subj.nfb.$mask.1D

                        3dDeconvolve -input $workdir/pb04.$subj.r01.scale+tlrc.HEAD $workdir/pb04.$subj.r02.scale+tlrc.HEAD $workdir/pb04.$subj.r03.scale+tlrc.HEAD                \
                        -polort A -num_stimts 14                                                                                                 \
                        -mask $rootdir/backup/masks/full_mask.group+tlrc.HEAD                                                                          \
                        -stim_times 1 $rootdir/backup/regressors/{$subj}_stimP.txt 'BLOCK(2,1)' -stim_label 1 primacy           \
                        -stim_times 2 $rootdir/backup/regressors/{$subj}_stimC.txt 'BLOCK(2,1)' -stim_label 2 ctl           \
                        -stim_times 3 $rootdir/backup/regressors/{$subj}_stimF.txt 'BLOCK(2,1)' -stim_label 3 fb           \
                        -stim_times 4 $rootdir/backup/regressors/{$subj}_stimNF.txt 'BLOCK(2,1)' -stim_label 4 nfb           \
                        -stim_file 5 $workdir/motion_demean.$subj.r01_r03.1D'[0]' -stim_base 5 -stim_label 5 roll                           \
                        -stim_file 6 $workdir/motion_demean.$subj.r01_r03.1D'[1]' -stim_base 6 -stim_label 6 pitch                          \
                        -stim_file 7 $workdir/motion_demean.$subj.r01_r03.1D'[2]' -stim_base 7 -stim_label 7 yaw                            \
                        -stim_file 8 $workdir/motion_demean.$subj.r01_r03.1D'[3]' -stim_base 8 -stim_label 8 dS                             \
                        -stim_file 9 $workdir/motion_demean.$subj.r01_r03.1D'[4]' -stim_base 9 -stim_label 9 dL                             \
                        -stim_file 10 $workdir/motion_demean.$subj.r01_r03.1D'[5]' -stim_base 10 -stim_label 10 dP                             \
                        -stim_file 11 $rootdir/text_data/ppi_seed_ts.$subj.$mask.1D -stim_label 11 seed                                   \
                        -stim_file 12 $rootdir/text_data/Inter_neur.$subj.ctl.$mask.1D -stim_label 12 PPI_ctl                                     \
                        -stim_file 13 $rootdir/text_data/Inter_neur.$subj.fb.$mask.1D -stim_label 13 PPI_fb                                     \
                        -stim_file 14 $rootdir/text_data/Inter_neur.$subj.nfb.$mask.1D -stim_label 14 PPI_nfb                                     \
                        -rout -tout -x1D $rootdir/ppi_results/X.xmat.$subj.$mask.1D -x1D_uncensored $rootdir/ppi_results/Xuc.xmat.$subj.$mask.1D  \
                        -bucket $rootdir/ppi_results/PPIstat.$subj.$mask
        end
end

#                        -stim_file 12 $rootdir/text_data/Inter_neur.$subj.primacy.$mask.1D -stim_label 12 PPI_primacy                                     \

