set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Plugin 'SirVer/ultisnips'
Plugin 'godlygeek/tabular'
Plugin 'junegunn/goyo.vim'
Plugin 'honza/vim-snippets'
Plugin 'scrooloose/nerdtree'
Plugin 'jiangmiao/auto-pairs'
Plugin 'valloric/YouCompleteMe'
Plugin 'vim-scripts/Conque-GDB'
Plugin 'vim-scripts/DoxygenToolkit.vim'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'merlinrebrovic/focus.vim'

call vundle#end()            " required
filetype plugin indent on    " required

" Set
" ===
set ruler
set number
set hidden
set mouse=""
set showcmd
set smarttab
set wildmenu
set hlsearch
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
set backupdir=/tmp
set directory=/tmp
set encoding=utf-8
set foldmethod=indent
set switchbuf=useopen
set ignorecase smartcase
set wildmode=longest,list
set backspace=indent,eol,start
set t_Co=256

syntax on

" Let
" ===
let mapleader = ";"
let g:tex_flavor='latex'

" airline
let g:airline_theme='bubblegum'
"let g:airline_theme='dark'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1

" YouCompleteMe

let g:SuperTabDefaultCompletionType = '<C-n>'
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:ycm_python_binary_path = '/usr/bin/python3'
let g:ycm_server_python_interpreter = '/usr/bin/python3'
let g:ycm_extra_conf_globlist = ['/home/rod/src/phylanx/*', '/home/rod/src/hpx/*']
let g:ycm_server_log_level = 'debug'
let g:ycm_confirm_extra_conf = 0
let g:ycm_max_diagnostics_to_display = 8
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_filetype_whitelist= {
      \ 'c': 1,
      \ 'cu': 1,
      \ 'cpp': 1,
      \ 'python': 1,
      \ 'py': 1
      \}
"let g:ycm_global_ycm_extra_conf = '/home/rod/.vim/bundle/YouCompleteMe/.ycm_extra_conf.py'

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" GoYo
let g:goyo_width = 120
let g:goyo_height = 50
let g:goyo_linenr = 1


" set author for Doxigen
let g:DoxygenToolkit_authorName="R. Tohid"

let g:ConqueTerm_Color = 2
let g:ConqueTerm_CloseOnEnd = 1
let g:ConqueTerm_StartMessages = 0

au FileType python setlocal formatprg=autopep8\ -
au FileType text setlocal spell spelllang=en_us
au FileType tex setlocal spell spelllang=en_us

"autocmd FileType *.cu set ft=cpp
autocmd FileType,BufNewFile,BufReadPost *.cu set filetype=cpp
autocmd FileType,BufNewFile,BufReadPost *.cc set filetype=cpp
autocmd FileType,BufNewFile,BufReadPost *.bak set filetype=cpp

" Maps
"=====
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l


" Commands
"=========
nnoremap <Leader>m :w <CR> :make<CR>
nnoremap <Leader>S :%s/\<<C-r><C-w>\>//g<Left><Left>
nnoremap <Leader>su :s/\<<C-r><C-w>\>//g<Left><Left>
nnoremap <Leader>T :tabnew 
nnoremap <Leader>d :Dox<cr>
nnoremap <Leader>D :w !diff % -<cr>
nnoremap <Leader>n :NERDTree<cr>
nnoremap <Leader>g :Goyo<cr>
nnoremap <Leader>G :Goyo!<cr>

nnoremap  <Leader>v :vsp 
nnoremap  <Leader>V :belowright vsp 
nnoremap  <Leader>h :sp 
nnoremap  <Leader>H :belowright sp 

command Emtext :normal i {\em{}}<Left><Left><ESC>
nnoremap  <Leader>e :Emtext<CR>
command Bftext :normal i {\textbf{}}<Left><Left><ESC>
nnoremap  <Leader>b :Bftext<CR>
" Avoid ESC
vmap <C-c> <Esc>
imap <C-c> <Esc>

" Get rid of Ex mode
nnoremap Q <nop>

" New line with ctrl+n
nnoremap <C-n> i<CR><ESC>

" Use Space to clear search buffer
nnoremap <silent> <space> :nohlsearch <CR><C-l>

map <C-\> :vsp <CR>:exec("YcmCompleter GoTo")<CR>
map <C-]> :sp <CR>:exec("YcmCompleter GoTo")<CR>

" Color
" =====
colorscheme molokai
"-airline

" Styling
" =======
map  <F2> gg<S-v>G:pyf /opt/llvm/share/clang/clang-format.py<CR><C-o>
imap <F2> <ESC>gg<S-v>G:pyf /opt/llvm/share/clang/clang-format.py<CR>i

let g:focus_use_default_mapping = 0
nmap <F1> <Plug>FocusModeToggle

set listchars=tab:›\ ,trail:⋅,space:.

nnoremap <leader>l :call ListToggle()<cr>

function! ListToggle()
      if &list
        set list!
    else
        set list
    endif
endfunction

