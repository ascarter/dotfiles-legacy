" vimrc
" Multi-platform vimrc for software development
"
" Author: Andrew Carter <ascarter@uw.edu>
" MIT License

set nocompatible
filetype off
let mapleader=","

" =====================================
" Plugins
" =====================================
" Enable extend % matching
runtime macros/matchit.vim

" Setup vim plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')
" Status line
Plug 'itchyny/lightline.vim'

" Color schemes
Plug 'ajh17/Spacegray.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'arcticicestudio/nord-vim'
Plug 'dracula/vim'
Plug 'kjssad/quantum.vim'
call plug#end()

" =====================================
" UI
" =====================================

" Color scheme
"set termguicolors
set background=dark
colorscheme quantum
let g:lightline = { 'colorscheme': 'quantum' }

" Turn off blinking cursor
" set guicursor+=n:blinkon0

" Flash screen only - no beep
set visualbell

" Show line numbers
set number

" Set fill characters
set fillchars=vert:\ ,fold:-

" Status line
if has('statusline')
	" Mode is shown by lightline
	set noshowmode
	set laststatus=2
	" set statusline=%<%f%{tagbar#currenttag('[%s]\ ','')}\ %w%h%m%r%=%-14.(%l,%c%V%)\ %P
endif

set hidden
set cursorline
set modeline
set ruler
set title

" Searching
set showmatch
set incsearch
set hlsearch
set ignorecase
set smartcase

" Completion
set wildmenu
set wildmode=list:longest
set wildignore=*.o,*.obj,*~,*DS_Store*

" Folding
set foldenable
set foldmethod=syntax
" Default to expanded
set foldlevel=10
"set foldcolumn=1

" netrw
let g:netrw_banner=0
let g:netrw_alto=&sb
let g:netrw_altv=&spr
let g:netrw_list_hide='.git,.DS_Store,.*\.swp$'
let g:netrw_liststyle=3
let g:netrw_preview = 1
" let g:netrw_winsize=20

" Window management

" Adjust viewports to the same size
map <Leader>= <C-w>=
imap <Leader>= <ESC> <C-w>=

" Tagbar
nmap <F8> :TagbarToggle<CR>

let g:tagbar_autoshowtag = 1
let g:tagbar_autopreview = 1
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent -f "-"'
\ }

" Enable Dash search
if has('macunix')
	:nmap <silent> <leader>d <Plug>DashSearch
endif

" =====================================
" Syntax and file types
" =====================================

set encoding=utf-8
syntax enable
filetype on
filetype plugin on
filetype indent on

" Whitespace
set nowrap
set autoindent

" Go
let g:go_fmt_command = "gofmt"

" =====================================
" GUI settings
" =====================================

if has("gui_running")
	" GUI color scheme
	" colorscheme nord

	" Set lightline colors
	" let g:lightline = { 'colorscheme': ( &background == "light" ? 'PaperColor' : 'dark' ) }

	" Set standard starting window size
	if &diff
		set lines=40 columns=160
	else
		set lines=40 columns=100
	endif

	" Turn off toolbar
	set guioptions-=T
	map <silent> <C-F1> :call ToggleGuiOption("T")<CR>

	
	if has('gui_macvim')
		" Mac OS X
		" set macthinstrokes
		set guifont=SF\ Mono\ Regular:h13,Menlo:h13
		let macvim_hig_shift_movement = 1
		au FocusLost * set transp=5
		au FocusGained * set transp=0

		" Typical Mac OS X keymappings
		" cmd-[ / cmd-] to increase/decrease indentation
		vmap <D-]> >gv
		vmap <D-[> <gv
		map <D-]> >>
		map <D-[> <<

		" cmd-<0...9> to switch tabs
		map  <D-0> 0gt
		imap <D-0> <Esc>0gt
		map  <D-1> 1gt
		imap <D-1> <Esc>1gt
		map  <D-2> 2gt
		imap <D-2> <Esc>2gt
		map  <D-3> 3gt
		imap <D-3> <Esc>3gt
		map  <D-4> 4gt
		imap <D-4> <Esc>4gt
		map  <D-5> 5gt
		imap <D-5> <Esc>5gt
		map  <D-6> 6gt
		imap <D-6> <Esc>6gt
		map  <D-7> 7gt
		imap <D-7> <Esc>7gt
		map  <D-8> 8gt
		imap <D-8> <Esc>8gt
		map  <D-9> 9gt
		imap <D-9> <Esc>9gt

	elseif has('gui_gtk2')
		" Linux
		set guifont=Source\ Code\ Pro\ Medium\ 12,Monospace\ 12
	elseif has('gui_win32')
		" Windows
		set guifont=Source\ Code\ Pro:h12,Consolas:h11,Lucida\ Console:h12
	endif
endif


" =====================================
" Functions
" =====================================

function ToggleGuiOption(option)
    " If a:option is already set in guioptions, then we want to remove it
    if match(&guioptions, "\\C" . a:option) > -1
	exec "set guioptions-=" . a:option
    else
	exec "set guioptions+=" . a:option
    endif
endfunction

