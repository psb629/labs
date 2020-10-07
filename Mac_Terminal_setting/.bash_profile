# Source bashrc
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# aliases go here 
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias la='ls -al'
alias ll='ls -l -tr'
alias cl='clear'
alias cdGDp='cd /Volumes/T7SSD1/GD'
alias cdGDr='cd ~/Desktop/GD'

# colors
GREEN='\e[0;32m\]'
B_GREEN='\e[1;32m\]'
MAGENTA='\e[0;35m\]'
B_MAGENTA='\e[1;35m\]'
YELLOW='\e[0;33m\]'
B_YELLOW='\e[1;33m\]'
RED='\e[0;31m'
BLUE='\e[0;34m'
B_BLUE='\e[1;34m'
CYAN='\e[0;36m\]'
COLOR_END='\[\033[0m\]'

#export PS1="${MAGENTA}\$(date +%Y-%m-%d-%a) \
#${B_YELLOW}\$(date +%T) \
#${GREEN}\u \
#${B_MAGENTA}\h \
#${B_BLUE}\w \n"
export PS1="\$(date +%Y-%m-%d-%a) \$(date +%T) \u \w/"

# ls command color display & color setting
export CLICOLOR=1
export LSCOLORS=DxFxBxDxCxegedabagacad


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

ahdir=`apsearch -afni_help_dir`
if [ -f "$ahdir/all_progs.COMP.bash" ]
then
   . $ahdir/all_progs.COMP.bash
fi
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/opt/X11/lib/flat_namespace


# FSL Setup
FSLDIR=/usr/local/fsl
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
. ${FSLDIR}/etc/fslconf/fsl.sh

