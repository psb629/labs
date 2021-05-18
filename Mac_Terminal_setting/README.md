To install several programs, copy+paste in your terminal!
-----------------------------
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/psb629/labs/master/Mac_Terminal_setting/install.sh)"
- - -
my favorite Zsh-theme is amuse
-----------------------------
- - -
If you see the below error message after the installation.
	"complete:96: bad math expression: operand expected at end of string"
# From ~/.zshrc, the following passages shall be erased.
	if [ -f $HOME/.afni/help/all_progs.COMP.zsh ]
	then
 		autoload -U +X bashcompinit && bashcompinit
		autoload -U +X compinit && compinit \
			&& source $HOME/.afni/help/all_progs.COMP.zsh
	fi
- - -
installation logs
-----------------------------
> 2020년 11월 21일 토요일 18시 50분 10초 JST
> 2020년 11월 23일 월요일 15시 41분 03초 KST
> Fri Dec 4 12:25:12 2020
> 2020년 12월 23일 수요일 16시 26분 50초 KST
> 2020년 12월 24일 목요일 10시 59분 03초 KST
> 2020년 12월 24일 목요일 11시 17분 22초 KST
> 2020년 12월 24일 목요일 11시 18분 10초 KST
> 2020년 12월 24일 목요일 11시 18분 54초 KST
> 2020년 12월 24일 목요일 22시 50분 32초 JST
> 2021년 01월 7일 목 오후 11:50:19
> _mbsetupuser clmn: 2021년 3월 10일 수요일 10시 41분 12초 KST
