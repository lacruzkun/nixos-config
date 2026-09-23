set number
set relativenumber

filetype plugin indent on
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set smartindent

set backspace=indent,eol,start

syntax on

autocmd BufNewFile,BufRead *.luau setf luau
autocmd FileType luau setlocal syntax=lua
