set nocompatible               " Be iMproved
set shortmess=atI " Quick start

if has('win32') || has('win64')
  " let $HOME=$VIM
  set runtimepath^=~/.vim
endif

call plug#begin('~/.vim/bundle')

" Plug 'mhinz/vim-startify'
Plug 'Valloric/YouCompleteMe'
Plug 'Shougo/vimproc.vim'
Plug 'Shougo/unite.vim'
" Plug 'Shougo/denite.nvim'
Plug 'morhetz/gruvbox'
" Plug 'bling/vim-bufferline'
Plug 'Shougo/neomru.vim'
" Plug 'Shougo/unite-session'
" Plug 'Shougo/neoyank.vim'
Plug 'Shougo/vimshell.vim'
Plug 'Shougo/vimfiler.vim'
" Plug 'Shougo/neocomplete'
Plug 'mbbill/undotree'
" Plug 'altercation/vim-colors-solarized'
Plug 'itchyny/lightline.vim'
" Plug 'othree/yajs.vim' " js syntax
" Plug 'gavocanov/vim-js-indent' " js indent
" Plug 'scrooloose/syntastic'
" Plug 'marijnh/tern_for_vim', { 'do': 'npm install' }
" Plug 'junegunn/rainbow_parentheses.vim'
" Plug 'nathanaelkane/vim-indent-guides'
Plug 'tpope/vim-commentary'
" Plug 'tpope/vim-surround'
" Plug 'tpope/vim-repeat'
" Plug 'mbbill/fencview'
call plug#end()

" ============ Encodeing ============
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,sjis,euc-kr,latin1
set fileformats=unix,dos

" ========== General Config ==========
syntax on           " Syntax highlighting
set mouse=a         " Enable mouse
set hidden          " Allow buffer switching without saving
set history=1000    " Enable Longer cmd history
set showmode        " Display the current mode
set number          " SHow line numbers
set showmatch       " Show matching brackets/parenthesis
set linespace=0     " No extra spaces between rows
set nowrap          " No wrap long lines
set linebreak       " Wrap lines at linebreaks
set winminheight=0  " Windows can be 0 line high
set laststatus=2    " Always show the statusline

" ========== Search ================
set incsearch       " Find as you type search
set hlsearch        " Highlight search terms
set ignorecase      " Case insensitive search
set smartcase       " Case sensitive when uppercase present

" ============ No Backup =========
set noswapfile
set nobackup

" =========== Persistent Undo =======
if !isdirectory('~/.vim/undo/')
    silent call mkdir('~/.vim/undo', 'p')
endif

if has("persistent_undo")
  set undodir=~/.vim/undo/
  set undofile
  set undolevels=1000
  set undoreload=10000
endif

" ============== Indentation ===========
set autoindent
set smartindent
set smarttab
set shiftwidth=2    " Use indents of 2 spaces
set expandtab       " Tabs are spaces, not tabs
set tabstop=2       " An indentation every 2 columns
set softtabstop=2   " Let backspace delete indent

" ======= Code Folding ======
"set foldenable      " Auto fold code
set foldmethod=indent
set foldlevel=999

" ========= Completion ========
set wildmenu        " Show list instead of just completing
set wildignorecase
set wildmode=list:longest,full
set wildignore=*.pyc

" ==============Navigation ==========
set backspace=indent,eol,start  " Backspace for dummies
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap to
set scrolljump=5                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor

" ================ UI =================
set background=dark
colorscheme gruvbox 
set cursorline      " Highlight current line

if has('gui_running')
  if has('win32')
      set guifont=Hack:h11
      " set guifont=Envy_Code_R:h11
      " set guifont=Consolas:h11
      set rop=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,renmode:4,taamode:1
    " set rop=type:directx,renmode:5,taamode:1
  else
    set guifont=Envy\ Code\ R\ 11
  endif
  " set guioptions+=b
  " set guioptions-=m                                 "tear off menu items
  " set guioptions-=T
else
  set t_Co=256
  set title       " Set terminal title
endif

" ================ Shortcut ==============

" Change map leader to ","
let mapleader = ","

" Quick edit and source vimrc
nmap <leader>v :e $MYVIMRC<CR>

augroup reload_vimrc
  autocmd!
  autocmd bufwritepost $MYVIMRC nested source $MYVIMRC
augroup END

set pastetoggle=<F12>   " Toggle paste mode

" Invoke sudo
cmap w!! %!sudo tee > /dev/null %

" Show whitespace, toggled with <leader>s
set listchars=tab:>-,trail:·,eol:¶
nmap <silent> <leader>s :set nolist!<CR>

" ================ Key Mapping ===============
imap jk <esc>
nnoremap ,cd :cd %:p:h<CR>:pwd<CR>
nmap <space> [unite]
nnoremap [unite] <nop>

nnoremap <silent> [unite]<space> :<C-u>Unite
  \ -buffer-name=files buffer file_mru bookmark file_rec/async<CR>

let g:unite_source_history_yank_enable = 1
nnoremap <space>y :Unite history/yank<cr>
nnoremap <space>s :Unite -quick-match buffer<cr>

" =============== Speecific Language Settings ==========
" python
autocmd BufRead *.py nmap <F5> :!python "%"<CR>
"let $PYTHONHOME='path\to\python'
"let $PYTHONPATH='path\to\python\Lib'

" Javascript
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2





" "Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" " Use neocomplete.
" let g:neocomplete#enable_at_startup = 1
" " Use smartcase.
" let g:neocomplete#enable_smart_case = 1
" " Set minimum syntax keyword length.
" let g:neocomplete#sources#syntax#min_keyword_length = 3
" let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" " Define dictionary.
" let g:neocomplete#sources#dictionary#dictionaries = {
"   \ 'default' : '',
"   \ 'vimshell' : $HOME.'/.vimshell_hist',
"   \ 'scheme' : $HOME.'/.gosh_completions'
"   \ }

" " Define keyword.
" if !exists('g:neocomplete#keyword_patterns')
"   let g:neocomplete#keyword_patterns = {}
" endif
" let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" " Plugin key-mappings.
" inoremap <expr><C-g>     neocomplete#undo_completion()
" inoremap <expr><C-l>     neocomplete#complete_common_string()

" " Recommended key-mappings.
" " <CR>: close popup and save indent.
" inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
" function! s:my_cr_function()
"   return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
"   " For no inserting <CR> key.
"   "return pumvisible() ? "\<C-y>" : "\<CR>"
" endfunction
" " <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" " <C-h>, <BS>: close popup and delete backword char.
" inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
" inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" " Close popup by <Space>.
" "inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=tern#Complete
" autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags







" ==Systastic

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['eslint']



if executable('pt')
  " Use pt (the platinum searcher)
  " https://github.com/monochromegane/the_platinum_searcher
	let g:unite_source_rec_async_command =
    \ ['pt', '--follow', '--nocolor', '--nogroup',
		\  '--hidden', '-g', '']
  let g:unite_source_grep_command = 'pt'
	let g:unite_source_grep_default_opts = '--nogroup --nocolor'
	let g:unite_source_grep_recursive_opt = ''
  let g:unite_source_grep_encoding = 'utf-8'
endif

let g:lightline = {
  \ 'colorscheme': 'gruvbox',
  \ }
