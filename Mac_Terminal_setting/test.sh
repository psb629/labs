#!/bin/bash

#### afni ####
cd ~
update=@update.afni.binaries
pack=macos_10.12_local
curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/$update
tcsh $update -package $pack -do_extras
cp $HOME/abin/AFNI.afnirc $HOME/.afnirc
rm ~/$update
