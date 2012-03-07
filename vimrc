set nocompatible

set encoding=utf-8

syntax enable
filetype on
filetype plugin on
filetype indent on

" Whitespace
" set nowrap
set tabstop=2
set shiftwidth=2
set softtabstop=2
set listchars=tab:\ \ ,trail:·
set nolist
set expandtab
set smarttab
set smartindent
set autoindent
set backspace=start,eol,indent whichwrap+=<,>,[,]

" set number
set cursorline
set modeline

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

set scs
set showtabline=1
set ruler

" Turn off blinking cursor
set guicursor+=n:blinkon0

" Use system clipboard
" set clipboard=unnamed

autocmd FileType javascript set tabstop=4 shiftwidth=4 softtabstop=4 expandtab
autocmd FileType ruby       set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType rdoc       set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType eruby      set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType haml       set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType sass       set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType cucumber   set tabstop=2 shiftwidth=2 softtabstop=2 expandtab
autocmd FileType python     set tabstop=4 shiftwidth=4 softtabstop=4 expandtab textwidth=79 cinwords=if,elif,else,for,while,with,try,except,finally,def,class
autocmd FileType make       set noexpandtab
autocmd FileType markdown   set wrap wrapmargin=2 textwidth=72|map <buffer> <Leader>p :Hammer<CR>
autocmd BufNewFile,BufRead *.json set ft=javascript

set foldenable
set foldmethod=syntax
set foldlevel=10

" Don't create extra files
"set nobackup
"set nowritebackup
"set noswapfile

" Status line
set laststatus=2
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set titlestring=%t%(\ -\ %{expand(\"%:~:.:h\")}%)%(\ [%n]%)%(\ %M%)%(\ %a%)

if has("unix")
  " Invisible character symbols (match textmate)
  set listchars=tab:▸\ ,eol:¬
endif

" Mappings
let mapleader = "\\"

if has('gui_running')
  set background=light
else
  set background=dark
endif

colorscheme github

" MacVIM shift+arrow keys behavior
if has("gui_macvim")
  let macvim_hig_shift_movement = 1
endif

" % to bound from do to end
runtime! macros/matchit.vim
