#!/bin/bash
reset
set term x11 enhanced
set term png enhanced
set grid

sigma=3.0**0.5
mean=1.0
pi=3.14159265
set key r t
f_1(x)=exp(-(x-mean)*(x-mean)/(2*sigma*sigma))/(sigma*sigma*2.0*pi)**0.5	#Gaussian
g_1(x)=2.0	#uniform
set output "Pareto_distribution.png"
p 'printf.dat' u 1:2 w lp lw 1 t "PDF",'printf.dat' u 1:3 w lp lw 1 t "CDF"

#set output "HW3.png"
#set title "Bethe Lattice({/Symbol t=2.5}, {/Symbol s}=0.5)"
#set xlab "s/s_{/Symbol x}"
#set ylab "s^{/Symbol t}n(s,p)"
#tau=2.5
#sigma=0.5
#z=3
#p_c=1/(z-1)
#s_xi(p)=abs(p-p_c)**(-1/sigma)
#p 'plot1.dat' u ($2/s_xi($1)):($2**tau*$4) w l t "p=0.5",'plot2.dat' u ($2/s_xi($1)):($2**tau*$4) w l t "p=0.75",'plot3.dat' u ($2/s_xi($1)):($2**tau*$4) w l t "p=0.875",'plot4.dat' u ($2/s_xi($1)):($2**tau*$4) w l t "p=0.9375"

##### 2D Ising : magnetization ######
#tau_c=2.26918531421
#f(x)=x**(1./8.)*1.236134
#g(x)=x**(-7./4.)*(0.066816)

#set ylab "<m>" font ',20'
#set output "fig_2_26a.png"
#set xlab "{/Symbol t}/{/Symbol t}_c" font 10
#set xrange [0:1.5]
#unset key
#p '2D_Ising.dat' u 1:2 w lp lw 1,
#set output "fig_2_26b.png"
#set key l t
#set logscale xy
#set xlab "({/Symbol t}_c-{/Symbol t})/{/Symbol t}" font ',20'
#p '2D_Ising.dat' u (1.-$1):2 w lp lw 1 t "100x100",f(x) t "slope=1/8"
#set ylab "<m>" font ',20'
#set logscale xy
#set xlab "|{/Symbol t}-{/Symbol t}_c|/{/Symbol t}_c"
#p '2D_Ising.dat' u (abs($1*tau_c-tau_c)/tau_c):2 w lp lw 1 t "100x100",

#set ylab "{/Symbol c}({/Symbol t})" font ',20'
#set output "fig_2_27a.png"
#unset key
#set xlab "{/Symbol t}/{/Symbol t}_c"
#p '2D_Ising_add.dat' u 1:6 w lp lw 1,
#set output "fig_2_27b.png"
#set logscale xy
#set xlab "|{/Symbol t}-{/Symbol t}_c|/{/Symbol t}_c" font ',20'
#p '2D_Ising_add.dat' u ((1.-$1>0.)?(1.-$1):(NaN)):6 w lp lw 1 t "{/Symbol t}>{/Symbol t}_c",'2D_Ising_add.dat' u ((1.-$1<0.)?($1-1.):(NaN)):6 w lp lw 1 t "{/Symbol t}<{/Symbol t}_c",g(x) t "slope=-7/4"

#set xlab "{/Symbol t}/{/Symbol t}_c"
#unset key
#set output "fig_2_28a.png"
#set ylab "E" font ',10'
#p '2D_Ising.dat' u 1:3 w lp lw 1,
#set output "fig_2_28b.png"
#set ylab "c({/Symbol t})" font ',20'
#p '2D_Ising_add.dat' u 1:5 w lp lw 1,

##### 2D percolation ######
#set key l t
#p_c=0.59274621
#p_c128=0.614952
#f(x)=x**(5./36.)*0.960507
#g(x)=x**(-43./18.)*0.312198
#set ylab "P_{infty}" font ',20'

#set ylab "{/Symbol c}(p)" font ',20'
#set output "fig_1_14a.png"
#p '2D_percolation.dat' u 1:2 w lp lw 1,
#set output "fig_1_14b.png"
#set xlab "(p-p_c)" font ',20'
#set logscale xy
#p '2D_percolation.dat' u ($1-p_c128):2 w lp lw 1 t "128x128",f(x) t "slope=5/36"

#set output "fig_1_15a.png"
#set xlab "p" font ',20'
#set logscale y
#p '2D_percolation.dat' u 1:3 w lp lw 1,
#set output "fig_1_15b.png"
#set yrange [0.1:100000]
#set xlab "|p-p_c|" font ',20'
#set logscale xy
#p '2D_percolation.dat' u (($1-p_c128>0.)?($1-p_c128):(NaN)):3 w lp lw 1 t "p>p_c",'2D_percolation.dat' u (($1-p_c128<0.)?(p_c128-$1):(NaN)):3 w lp lw 1 t "p<p_c",g(x) t "slope=-43/18"
