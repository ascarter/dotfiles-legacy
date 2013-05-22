" Vim color file
"
" Author: Andrew Carter <ascarter@gmail.com>
"
" Note: Developer color scheme inspired by Apple Pro applications
"
" ********************************************************************************
" The following are the preferred 16 colors for your terminal
"           Colors      Bright Colors
" Black     #4E4E4E     #7C7C7C
" Red       #FF6C60     #FFB6B0
" Green     #A8FF60     #CEFFAB
" Yellow    #FFFFB6     #FFFFCB
" Blue      #96CBFE     #FFFFCB
" Magenta   #FF73FD     #FF9CFE
" Cyan      #C6C5FE     #DFDFFE
" White     #EEEEEE     #FFFFFF
" ********************************************************************************

set background=dark
highlight clear
if exists("syntax_on")
	syntax reset
endif

let g:colors_name = "pro"

hi Normal guifg=#F1F1F1 guibg=#000000 ctermfg=NONE ctermbg=NONE

" Cursor
" Pro terminal:
" Cursor = #4d4d4d
" Selection = #404040
" iTunes scrollbar = #8f8f8f
" #1f1f1f
hi Cursor	    guifg=#F1F1F1 guibg=#4D4D4D
" Alternate cursor
"hi Cursor	    guifg=#F1F1F1 guibg=#8F8F8F
hi CursorLine	guifg=NONE    guibg=#1F1F1F  guisp=NONE cterm=underline
hi CursorColumn	guifg=NONE    guibg=#121212

" Diff
"hi DiffAdd	guifg=#003300 guibg=#DDFFDD gui=none
"hi DiffChange	guifg=NONE    guibg=#ececec gui=none
"hi DiffText	guifg=#000033 guibg=#DDDDFF gui=none
"ihi DiffDelete	guifg=#DDCCCC guibg=#FFDDDD gui=none

" {{{ Folding / Line Numbering / Status Lines
"hi LineNr	guifg=#6F6868 guibg=#CBCBCB ctermfg=darkgrey ctermbg=grey
hi LineNr	guifg=#6F6868 guibg=#000000 ctermfg=darkgrey ctermbg=black
hi NonText	guifg=#6F6868 guibg=#000000 ctermfg=black
hi Folded	guifg=#6F6868 guibg=#C9C9C9 gui=bold
hi FoldColumn	guifg=#6F6868 guibg=#A6A6A6 gui=bold

hi VertSplit	guifg=#CBCBCB guibg=#CBCBCB gui=none
"hi StatusLine   guifg=#6F6868 guibg=#F1F1F1 gui=bold ctermfg=grey ctermbg=darkgrey
"hi StatusLineNC guifg=#6F6868 guibg=#CBCBCB gui=italic ctermfg=darkgrey ctermbg=grey
hi StatusLine   guifg=#FFFFFF guibg=#3F3F3F gui=bold ctermfg=darkgrey ctermbg=grey
hi StatusLineNC guifg=#A8A3A3 guibg=#333333 gui=italic ctermfg=darkgrey ctermbg=black
" }}}

"" {{{ Misc
"hi ModeMsg		guifg=#990000
"hi MoreMsg		guifg=#990000

"hi Title		guifg=#ef5939
"hi WarningMsg	guifg=#ef5939
"hi SpecialKey   guifg=#177F80 gui=italic

"hi MatchParen	guibg=#cdcdfd guifg=#000000
"hi Underlined	guifg=#000000 gui=underline
"hi Directory	guifg=#990000
"" }}}

" {{{ Search, Visual, etc
hi Visual	guifg=NONE guibg=#404040 gui=none
"hi VisualNOS    guifg=#FFFFFF guibg=#204a87 gui=none
hi IncSearch	guifg=#A5C8FF guibg=#6F6868 gui=bold ctermfg=NONE ctermbg=NONE cterm=reverse
hi Search	guifg=#F1F1F1 guibg=#7785B1 gui=bold ctermfg=NONE ctermbg=NONE cterm=reverse
" }}}

" {{{ Syntax groups
hi Comment		guifg=#7C7C7C guibg=NONE gui=italic      ctermfg=darkgrey    ctermbg=NONE
hi Constant		guifg=#99CC99 guibg=NONE gui=NONE        ctermfg=darkcyan    ctermbg=NONE
hi Identifier	guifg=#96CBFE guibg=NONE gui=NONE        ctermfg=cyan        ctermbg=NONE
hi Statement	guifg=#6699CC guibg=NONE gui=NONE        ctermfg=darkgreen   ctermbg=NONE
hi PreProc		guifg=#96CBFE guibg=NONE gui=NONE        ctermfg=magenta     ctermbg=NONE
hi Type			guifg=#FFFFB6 guibg=NONE gui=NONE        ctermfg=green       ctermbg=NONE
hi Special		guifg=#E18964 guibg=NONE gui=NONE        ctermfg=red         ctermbg=NONE
hi Underlined	guifg=NONE    guibg=NONE gui=underline   ctermfg=NONE        ctermbg=NONE cterm=underline
hi Ignore		guifg=#DBDBDB guibg=NONE gui=NONE        ctermfg=darkgrey    ctermbg=NONE
hi Error		guifg=NONE    guibg=NONE gui=undercurl   ctermfg=white       ctermbg=red
hi Todo			guifg=#DBDBDB guibg=NONE gui=bold,italic ctermfg=lightyellow ctermbg=NONE
" }}}

" {{{ Completion menus
"hi WildMenu     guifg=#7fbdff guibg=#425c78 gui=none

"hi Pmenu        guibg=#808080 guifg=#ffffff gui=bold
hi PmenuSel     guibg=#cdcdfd guifg=#000000 gui=italic
"hi PmenuSbar    guibg=#000000 guifg=#444444
"hi PmenuThumb   guibg=#aaaaaa guifg=#aaaaaa
"" }}}

"" {{{ Spelling
"hi spellBad     guisp=#fcaf3e
"hi spellCap     guisp=#73d216
"hi spellRare    guisp=#fcaf3e
"hi spellLocal   guisp=#729fcf
"" }}}

" {{{ Tabs (non-gui)
hi TabLine	guifg=#6F6868 guibg=#2B2B2B gui=none
hi TabLineFill	guifg=#6F6868 guibg=#2B2B2B gui=none
hi TabLineSel	guifg=#6F6868 guibg=#2B2B2B gui=bold
" }}}

" vim: sw=4 ts=4 foldmethod=marker
