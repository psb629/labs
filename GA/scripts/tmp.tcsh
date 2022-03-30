#!/bin/tcsh

if ( $#argv > 0 ) then
    set subj = $argv[1]
endif

set gg = `printf '%s' $subj | cut -c 1-2`
set nn = `printf '%s' $subj | cut -c 3-4`

echo $gg $nn
