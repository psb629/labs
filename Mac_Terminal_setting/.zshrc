## show $SHELL
echo $SHELL

## set zsh to be the default shell
# chsh -s $(which zsh)

## aliases go here 
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias la='ls -al'
alias ll='ls -l -tr'
alias cl='clear'
alias cnt='echo "# of directories : "; ll | grep ^d | wc -l ; echo "# of files : "; ll | grep ^- | wc -l'
alias dush='du -sh ./*'
alias top='top -o mem -O cpu'
alias afni='afni ~/abin/MNI152_T1_2009c+tlrc. '
