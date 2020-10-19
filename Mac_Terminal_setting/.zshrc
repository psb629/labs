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
alias cnt='echo "# of directories : "; ll | grep ^d | wc -l ; echo "# of files : "; ll | grep ^- | wc -l'
alias dush='du -sh ./*'

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

export PS1='%(?.%F{green}.%F{red})%n@%d # %f'

# ls command color display & color setting
export CLICOLOR=1
export LSCOLORS=DxFxBxDxCxegedabagacad
