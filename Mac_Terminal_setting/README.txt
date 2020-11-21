# =======================================================
## To install several programs, copy+paste in your terminal!
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/psb629/labs/master/Mac_Terminal_setting/install.sh)"

# =======================================================
## my favorite Zsh-theme is amuse

# =======================================================
## If you see the below error message after the installation.
"complete:96: bad math expression: operand expected at end of string"
# From ~/.zshrc, the following passages shall be erased.
if [ -f $HOME/.afni/help/all_progs.COMP.zsh ]
then
 	autoload -U +X bashcompinit && bashcompinit
	autoload -U +X compinit && compinit \
		&& source $HOME/.afni/help/all_progs.COMP.zsh
fi
# =======================================================

