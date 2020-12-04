#!/bin/bash
reset
#set term x11 enhanced
set term postscript enhanced color
#set output "n_max=2(even).eps"
set format y "%.2te^{%+02T}"
set grid
set xtics 0.001 font ",15"
set ytics font ",15"
set mxtics 10
set mytics 10
set key font ",15"


set title "density, t=0.200, L=200"
set key t l
set xlab "{/Symbol m}" font ",20"
set ylab "<n_{j}>" font ",20"
#p './Data/n_max=2/random/t=0.20000,chi=8_expectation.dat' u 3:5 w lp lw 1 ps 0.4 t "{/Symbol c}=8",'./Data/n_max=2/random/t=0.20000,chi=10_expectation.dat' u 3:5 w lp lw 1 ps 0.4 t "{/Symbol c}=10",'./Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u 3:5 w lp lw 1 ps 0.4 t "{/Symbol c}=12",'./Data/n_max=2/random/t=0.20000,chi=14_expectation.dat' u 3:5 w lp lw 1 ps 0.4 t "{/Symbol c}=14",'./Data/n_max=2/random/t=0.20000,chi=16_expectation.dat' u 3:5 w lp lw 1 ps 0.4 t "{/Symbol c}=16",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u 3:5 w lp lw 1 ps 0.4 t "{/Symbol c}=18",'./Data/n_max=2/random/t=0.20000,chi=20_expectation.dat' u 3:5 w lp lw 1 ps 0.4 t "{/Symbol c}=20",
#p './Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==80)?$3:NaN):(($1==80)?abs($5-1.0):NaN) w lp ps 0.4 t "L=80",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==100)?$3:NaN):(($1==100)?abs($5-1.0):NaN) w lp ps 0.4 t "L=100",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==120)?$3:NaN):(($1==120)?abs($5-1.0):NaN) w lp ps 0.4 t "L=120",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==140)?$3:NaN):(($1==140)?abs($5-1.0):NaN) w lp ps 0.4 t "L=140",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==160)?$3:NaN):(($1==160)?abs($5-1.0):NaN) w lp ps 0.4 t "L=160",

set title "expectation value, t=0.200, L=200"
set key t r
set xlab "{/Symbol m}" font ",20"
set ylab "<b_{j}>" font ",20"
#p './Data/n_max=2/random/t=0.20000,chi=8_expectation.dat' u 3:(abs($6)) w lp lw 1 ps 0.4 t "{/Symbol c}=8",'./Data/n_max=2/random/t=0.20000,chi=10_expectation.dat' u 3:(abs($6)) w lp lw 1 ps 0.4 t "{/Symbol c}=10",'./Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u 3:(abs($6)) w lp lw 1 ps 0.4 t "{/Symbol c}=12",'./Data/n_max=2/random/t=0.20000,chi=14_expectation.dat' u 3:(abs($6)) w lp lw 1 ps 0.4 t "{/Symbol c}=14",'./Data/n_max=2/random/t=0.20000,chi=16_expectation.dat' u 3:(abs($6)) w lp lw 1 ps 0.4 t "{/Symbol c}=16",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u 3:(abs($6)) w lp lw 1 ps 0.4 t "{/Symbol c}=18",'./Data/n_max=2/random/t=0.20000,chi=20_expectation.dat' u 3:(abs($6)) w lp lw 1 ps 0.4 t "{/Symbol c}=20",
#p './Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u (($1==20)?$3:NaN):(($1==20)?abs($6):NaN) w p ps 0.4 t "{/Symbol c}=12, L=20",'./Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u (($1==40)?$3:NaN):(($1==40)?abs($6):NaN) w p ps 0.4 t "{/Symbol c}=12, L=40",'./Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u (($1==60)?$3:NaN):(($1==60)?abs($6):NaN) w p ps 0.4 t "{/Symbol c}=12, L=60",'./Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u (($1==80)?$3:NaN):(($1==80)?abs($6):NaN) w p ps 0.4 t "{/Symbol c}=12, L=80",'./Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u (($1==100)?$3:NaN):(($1==100)?abs($6):NaN) w p ps 0.4 t "{/Symbol c}=12, L=100",'./Data/n_max=2/random/t=0.20000,chi=12_expectation.dat' u (($1==120)?$3:NaN):(($1==120)?abs($6):NaN) w p ps 0.4 t "{/Symbol c}=12, L=120",

set title "spectrum, t=0.200"
set xlab "{/Symbol m}" font ",20"
set ylab "{/Symbol l}" font ",20"
#p './Data/n_max=2/random/t=0.20000,chi=8_spectrum.dat' u 2:4 w p ps 0.4 t "{/Symbol c}=8",'./Data/n_max=2/random/t=0.20000,chi=10_spectrum.dat' u 2:4 w p ps 0.4 t "{/Symbol c}=10",'./Data/n_max=2/random/t=0.20000,chi=12_spectrum.dat' u 2:4 w p ps 0.4 t "{/Symbol c}=12",'./Data/n_max=2/random/t=0.20000,chi=14_spectrum.dat' u 2:4 w p ps 0.4 t "{/Symbol c}=14",'./Data/n_max=2/random/t=0.20000,chi=16_spectrum.dat' u 2:4 w p ps 0.4 t "{/Symbol c}=16",'./Data/n_max=2/random/t=0.20000,chi=18_spectrum.dat' u 2:4 w p ps 0.4 t "{/Symbol c}=18",'./Data/n_max=2/random/t=0.20000,chi=20_spectrum.dat' u 2:4 w p ps 0.4 t "{/Symbol c}=20",

set title "entropy, t=0.200"
set xlab "{/Symbol m}" font ",20"
set ylab "S_{L/2}" font ",20"
#p './Data/n_max=2/random/t=0.20000,chi=8_entropy.dat' u 2:4 w lp lw 1 ps 0.4 t "{/Symbol c}=8",'./Data/n_max=2/random/t=0.20000,chi=10_entropy.dat' u 2:4 w lp lw 1 ps 0.4 t "{/Symbol c}=10",'./Data/n_max=2/random/t=0.20000,chi=12_entropy.dat' u 2:4 w lp lw 1 ps 0.4 t "{/Symbol c}=12",'./Data/n_max=2/random/t=0.20000,chi=14_entropy.dat' u 2:4 w lp lw 1 ps 0.4 t "{/Symbol c}=14",'./Data/n_max=2/random/t=0.20000,chi=16_entropy.dat' u 2:4 w lp lw 1 ps 0.4 t "{/Symbol c}=16",'./Data/n_max=2/random/t=0.20000,chi=18_entropy.dat' u 2:4 w lp lw 1 ps 0.4 t "{/Symbol c}=18",'./Data/n_max=2/random/t=0.20000,chi=20_entropy.dat' u 2:4 w lp lw 1 ps 0.4 t "{/Symbol c}=20",

set title "energy, t=0.200"
set key t l
set xlab "{/Symbol m}" font ",20"
set ylab "E_{g}-(-{/Symbol m}-1.5)" font ",20"
set format y "%.5te^{%+02T}"
f(x)=-x-1.5
#p './Data/n_max=2/random/t=0.20000,chi=8_entropy.dat' u 2:($5-f($2)) w lp lw 1 ps 0.4 t "{/Symbol c}=8",'./Data/n_max=2/random/t=0.20000,chi=10_entropy.dat' u 2:($5-f($2)) w lp lw 1 ps 0.4 t "{/Symbol c}=10",'./Data/n_max=2/random/t=0.20000,chi=12_entropy.dat' u 2:($5-f($2)) w lp lw 1 ps 0.4 t "{/Symbol c}=12",'./Data/n_max=2/random/t=0.20000,chi=14_entropy.dat' u 2:($5-f($2)) w lp lw 1 ps 0.4 t "{/Symbol c}=14",'./Data/n_max=2/random/t=0.20000,chi=16_entropy.dat' u 2:($5-f($2)) w lp lw 1 ps 0.4 t "{/Symbol c}=16",'./Data/n_max=2/random/t=0.20000,chi=18_entropy.dat' u 2:($5-f($2)) w lp lw 1 ps 0.4 t "{/Symbol c}=18",'./Data/n_max=2/random/t=0.20000,chi=20_entropy.dat' u 2:($5-f($2)) w lp lw 1 ps 0.4 t "{/Symbol c}=20",

d=0.0;
set title "correlation, t=0.200, L=128, {/Symbol c}=20"
set key t r
set xlab "r" font ",20"
set ylab "C(r)" font ",20"
set format y "%.3te^{%+02T}"

set output "<n>,chi=18.eps"
set xlab "{/Symbol m}" font ",20"
set ylab "<n_{i}>" font ",20"
set title "(<corr>-<><>)^{1/2}, {/Symbol c}=18"
p './Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==80)?($4):(NaN)):(($1==80)?(abs($8)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=80",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==100)?($4):(NaN)):(($1==100)?(abs($8)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=100",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==120)?($4):(NaN)):(($1==120)?(abs($8)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=120",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==140)?($4):(NaN)):(($1==140)?(abs($8)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=140",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==160)?($4):(NaN)):(($1==160)?(abs($8)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=160",
set title "expectation <n>, {/Symbol c}=18"
p './Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==80)?$3:NaN):(($1==80)?abs($5-1.0):NaN) w lp ps 0.4 t "L=80",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==100)?$3:NaN):(($1==100)?abs($5-1.0):NaN) w lp ps 0.4 t "L=100",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==120)?$3:NaN):(($1==120)?abs($5-1.0):NaN) w lp ps 0.4 t "L=120",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==140)?$3:NaN):(($1==140)?abs($5-1.0):NaN) w lp ps 0.4 t "L=140",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==160)?$3:NaN):(($1==160)?abs($5-1.0):NaN) w lp ps 0.4 t "L=160",
set title "(<corr>)^{1/2}-1.0, {/Symbol c}=18"
p './Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==80)?($4):(NaN)):(($1==80)?((abs($7)-1.0)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=80",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==100)?($4):(NaN)):(($1==100)?((abs($7)-1.0)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=100",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==120)?($4):(NaN)):(($1==120)?((abs($7)-1.0)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=120",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==140)?($4):(NaN)):(($1==140)?((abs($7)-1.0)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=140",'./Data/n_max=2/random/t=0.20000,chi=18_correlator.dat' u (($1==160)?($4):(NaN)):(($1==160)?((abs($7)-1.0)**0.5*$1**d):(NaN)) w lp ps 0.4 t "L=160",
set ylab "<b_{i}>" font ",20"
set title "expectation <b>, {/Symbol c}=18"
p './Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==80)?$3:NaN):(($1==80)?abs($6):NaN) w lp ps 0.4 t "L=80",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==100)?$3:NaN):(($1==100)?abs($6):NaN) w lp ps 0.4 t "L=100",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==120)?$3:NaN):(($1==120)?abs($6):NaN) w lp ps 0.4 t "L=120",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==140)?$3:NaN):(($1==140)?abs($6):NaN) w lp ps 0.4 t "L=140",'./Data/n_max=2/random/t=0.20000,chi=18_expectation.dat' u (($1==160)?$3:NaN):(($1==160)?abs($6):NaN) w lp ps 0.4 t "L=160",
