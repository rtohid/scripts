set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'VundleVim/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-airline/vim-airline'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" set
" ===
set ruler
set hidden
set number
set showcmd
"set mouse=a
set hlsearch
set smarttab
"set t_co=256
set wildmenu
set tabstop=4
set expandtab
set incsearch
set autoindent
set cursorline
set cmdheight=1
set laststatus=2
set shiftwidth=2
set history=10000
set colorcolumn=90
set encoding=utf-8
set foldmethod=marker
set switchbuf=useopen
set ignorecase smartcase
set wildmode=longest,list
set backspace=indent,eol,start

" Let
" ===
let mapleader = ';'
let g:tex_flavor='latex'

" Maps
" ====
nnoremap Q <nop>
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <Leader>h :sp 
nnoremap <Leader>v :vsp 
nnoremap <c-n> i<CR><ESC>
nnoremap <Leader>t :tabnew 
nnoremap <Leader>n :NERDTree<cr>
nnoremap <Leader>H :belowright sp 
nnoremap <Leader>V :belowright vsp 
nnoremap <Leader>D :w !diff % -<cr>
nnoremap <Leader>m :w <CR> :make<CR>
nnoremap <leader>jd :YcmCompleter GoTo<CR>
nnoremap <silent> <space> :nohlsearch <CR><C-l>
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
nnoremap <Leader>S :s/\<<C-r><C-w>\>//g<Left><Left>

syntax on
colorscheme monokai
