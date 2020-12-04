#!/bin/bash
reset
set term x11 enhanced
#set term postscript enhanced color
set grid
set format y "%.2tx10^{%+02T}"
#set output "gChgep0.005x12_g-dE.eps"
#set xlab "g"
#set ylab "{/Symbol c}^{0.0}{/Symbol d}E"
#set ylab "|{/Symbol d}E|"
#set title "L=20"
#p 'gChgep0.005x12_g-dE.dat' u 3:(abs($7*$2**0.0)) w l t "{/Symbol c}=12",
#set logscale y
#rep
#set ylab "E"
#p 'gChgep0.005x12_g-dE.dat' u 3:6 w l t "{/Symbol c}=12",

#set output "Fig_m.eps"
set title "{/Symbol c}=17" font ",10"
set xlab "g" font ",10"
set ylab "<m>" font ",10"
#p 'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==8)?($3):(NaN)):(($1==8)?($6):(NaN)) w lp t "L=8",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==16)?($3):(NaN)):(($1==16)?($6):(NaN)) w lp t "L=16",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==32)?($3):(NaN)):(($1==32)?($6):(NaN)) w lp t "L=32",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==64)?($3):(NaN)):(($1==64)?($6):(NaN)) w lp t "L=64",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==128)?($3):(NaN)):(($1==128)?($6):(NaN)) w lp t "L=128",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==256)?($3):(NaN)):(($1==256)?($6):(NaN)) w lp t "L=256",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==512)?($3):(NaN)):(($1==512)?($6):(NaN)) w lp t "L=512",
p 'm_chi10.dat' u 2:5 w l lw 2.5 t "{/Symbol c}=10"
set ylab "<m>L^{{/Symbol b}/{/Symbol n}}" font ",10"
set xlab "g" font ",10"
set yrange [0.:1.5]
#p 'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==8)?($3):(NaN)):(($1==8)?($6*$1**0.125):(NaN)) w lp t "L=8",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==16)?($3):(NaN)):(($1==16)?($6*$1**0.125):(NaN)) w lp t "L=16",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==32)?($3):(NaN)):(($1==32)?($6*$1**0.125):(NaN)) w lp t "L=32",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==64)?($3):(NaN)):(($1==64)?($6*$1**0.125):(NaN)) w lp t "L=64",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==128)?($3):(NaN)):(($1==128)?($6*$1**0.125):(NaN)) w lp t "L=128",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==256)?($3):(NaN)):(($1==256)?($6*$1**0.125):(NaN)) w lp t "L=256",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==512)?($3):(NaN)):(($1==512)?($6*$1**0.125):(NaN)) w lp t "L=512",
#p 'gChgEp0.005Chi13Tr_g-m_add2.dat' u (($1==8)?($3):(NaN)):(($1==8)?($6*$1**0.125):(NaN)) w lp t "L=8",'gChgEp0.005Chi13Tr_g-m_add2.dat' u (($1==16)?($3):(NaN)):(($1==16)?($6*$1**0.125):(NaN)) w lp t "L=16",'gChgEp0.005Chi13Tr_g-m_add2.dat' u (($1==32)?($3):(NaN)):(($1==32)?($6*$1**0.125):(NaN)) w lp t "L=32",'gChgEp0.005Chi13Tr_g-m_add2.dat' u (($1==64)?($3):(NaN)):(($1==64)?($6*$1**0.125):(NaN)) w lp t "L=64",'gChgEp0.005Chi13Tr_g-m_add2.dat' u (($1==128)?($3):(NaN)):(($1==128)?($6*$1**0.125):(NaN)) w lp t "L=128",'gChgEp0.005Chi13Tr_g-m_add2.dat' u (($1==512)?($3):(NaN)):(($1==512)?($6*$1**0.125):(NaN)) w lp t "L=512",
set ylab "<m>L^{{/Symbol b}/{/Symbol n}}" font ",10"
set xlab "(g-g_{c})L^{1/{/Symbol n}}" font ",10"
set xrange [-1.:1.]
unset yrange
#p 'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==8)?(($3-1.0)*$1):(NaN)):(($1==8)?($6*$1**0.125):(NaN)) w lp t "L=8",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==16)?(($3-1.0)*$1):(NaN)):(($1==16)?($6*$1**0.125):(NaN)) w lp t "L=16",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==32)?(($3-1.0)*$1):(NaN)):(($1==32)?($6*$1**0.125):(NaN)) w lp t "L=32",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==64)?(($3-1.0)*$1):(NaN)):(($1==64)?($6*$1**0.125):(NaN)) w lp t "L=64",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==128)?(($3-1.0)*$1):(NaN)):(($1==128)?($6*$1**0.125):(NaN)) w lp t "L=128",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==256)?(($3-1.0)*$1):(NaN)):(($1==256)?($6*$1**0.125):(NaN)) w lp t "L=256",'gChgEp0.005Chi17Tr_g-m_add2.dat' u (($1==512)?(($3-1.0)*$1):(NaN)):(($1==512)?($6*$1**0.125):(NaN)) w lp t "L=512",

#set output "Correlation_X11_B12_original.eps"
#set logscale xy
#set title "L=128, {/Symbol c}=11"
#set xlab "r"
#set ylab "C(r)"
#p 'gChgEp0.005Chi11_r-C(r).dat' u (($2==0.98)?($6):(NaN)):(($2==0.98)?($7):(NaN)) w lp t "g=0.98",'gChgEp0.005Chi11_r-C(r).dat' u (($2==0.99)?($6):(NaN)):(($2==0.99)?($7):(NaN)) w lp t "g=0.99",'gChgEp0.005Chi11_r-C(r).dat' u (($2==1.00)?($6):(NaN)):(($2==1.00)?($7):(NaN)) w lp t "g=1.00",'gChgEp0.005Chi11_r-C(r).dat' u (($2==1.01)?($6):(NaN)):(($2==1.01)?($7):(NaN)) w lp t "g=1.01",'gChgEp0.005Chi11_r-C(r).dat' u (($2==1.02)?($6):(NaN)):(($2==1.02)?($7):(NaN)) w lp t "g=1.02",'gChgEp0.005Chi11_r-C(r).dat' u (($2==1.03)?($6):(NaN)):(($2==1.03)?($7):(NaN)) w lp t "g=1.03",'gChgEp0.005Chi11_r-C(r).dat' u (($2==1.04)?($6):(NaN)):(($2==1.04)?($7):(NaN)) w lp t "g=1.04",

#set output "magnet_chi13Tr_h.eps"
#set title "{/Symbol c}=13, g=1.0" font ",10"
#set xlab "h" font ",10"
#set ylab "<m>" font ",10"
#set yrange[-1.:1.]
#p 'hChgEp0.005Chi13Tr_g-m.dat' u (($1==8)?($4):(NaN)):(($1==8)?($6):(NaN)) w lp t "L=8",'hChgEp0.005Chi13Tr_g-m.dat' u (($1==16)?($4):(NaN)):(($1==16)?($6):(NaN)) w lp t "L=16",'hChgEp0.005Chi13Tr_g-m.dat' u (($1==32)?($4):(NaN)):(($1==32)?($6):(NaN)) w lp t "L=32",'hChgEp0.005Chi13Tr_g-m.dat' u (($1==64)?($4):(NaN)):(($1==64)?($6):(NaN)) w lp t "L=64",'hChgEp0.005Chi13Tr_g-m.dat' u (($1==128)?($4):(NaN)):(($1==128)?($6):(NaN)) w lp t "L=128",'hChgEp0.005Chi13Tr_g-m.dat' u (($1==512)?($4):(NaN)):(($1==512)?($6):(NaN)) w lp t "L=512",

#set output 'fig_1.eps'
#set xlab "g" font ",10"
#set ylab "|{/Symbol D}E|" font ",10"
#set logscale y
#set key l t
#p 'printf_chi5.dat' u 2:(abs($5)) w lp t "{/Symbol c}=5",'printf_chi7.dat' u 2:(abs($5)) w lp t "{/Symbol c}=7",'printf_chi9.dat' u 2:(abs($5)) w lp t "{/Symbol c}=9",'printf_chi11.dat' u 2:(abs($5)) w lp t "{/Symbol c}=11",'printf_chi13.dat' u 2:(abs($5)) w lp t "{/Symbol c}=13",
