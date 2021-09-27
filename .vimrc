syntax on

set noerrorbells
set noexpandtab
set tabstop=2
set shiftwidth=2
set smartindent
set nu
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch

set background=dark

call plug#begin('~/.vim/plugged')
Plug 'joshdick/onedark.vim'
Plug 'ycm-core/YouCompleteMe'
call plug#end()

colorscheme onedark

hi normal guibg=NONE ctermbg=NONE
