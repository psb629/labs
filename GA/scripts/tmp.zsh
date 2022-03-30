#!/bin/zsh

list_nn=( 02 05 07 08 \
		  11 12 13 14 15 \
		  18 19 20 21 23 \
		  26 27 28 29 30 \
		  31 32 33 34 35 \
		  36 37 38 42 44 )
# ============================================================

foreach nn ($list_nn)
	foreach gg ('GA' 'GB')
		~/Github/labs/GA/scripts/afni_proc.tcsh $gg$nn
	end
end

