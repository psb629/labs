" Syntax Highlighting
if has("syntax")
    syntax on
endif

" Auto indenting
set autoindent
set cindent
set ts=4
set shiftwidth=4

" Show line numbers
set nu

" Load jellybeans which is syntax highlighting color
colorscheme jellybeans

" Place cursor where last modified
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |
\ endif

" Always mark the status bar
set laststatus=2
set statusline=\ %<%l:%v\ [%P]%=%a\ %h%m%r\ %F\
