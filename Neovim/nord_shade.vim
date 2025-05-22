" NordShade - A darker variant of the Nord theme for Neovim
" Maintainer: Matt Edmondson
" Version: 1.0.0

" Clear previous highlighting
highlight clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "nord_shade"

" Nord color palette (darker variant)
let s:nord0 = "#1a1e24"
let s:nord1 = "#242933"
let s:nord2 = "#2e3440"
let s:nord3 = "#3b4252"
let s:nord4 = "#434c5e"
let s:nord5 = "#4c566a"
let s:nord6 = "#d8dee9"
let s:nord7 = "#e5e9f0"
let s:nord8 = "#eceff4"
let s:nord9 = "#8fbcbb"
let s:nord10 = "#88c0d0"
let s:nord11 = "#81a1c1"
let s:nord12 = "#5e81ac"
let s:nord13 = "#bf616a"
let s:nord14 = "#d08770"
let s:nord15 = "#ebcb8b"
let s:nord16 = "#a3be8c"
let s:nord17 = "#b48ead"

" Basic UI
exec "hi Normal guifg=" . s:nord6 . " guibg=" . s:nord0
exec "hi LineNr guifg=" . s:nord4 . " guibg=" . s:nord0
exec "hi CursorLineNr guifg=" . s:nord9 . " guibg=" . s:nord1
exec "hi Cursor guifg=" . s:nord0 . " guibg=" . s:nord6
exec "hi CursorLine guibg=" . s:nord1
exec "hi ColorColumn guibg=" . s:nord1
exec "hi SignColumn guifg=" . s:nord4 . " guibg=" . s:nord0
exec "hi VertSplit guifg=" . s:nord2 . " guibg=" . s:nord0
exec "hi MatchParen guifg=" . s:nord8 . " guibg=" . s:nord4
exec "hi StatusLine guifg=" . s:nord8 . " guibg=" . s:nord3
exec "hi StatusLineNC guifg=" . s:nord6 . " guibg=" . s:nord1
exec "hi Pmenu guifg=" . s:nord6 . " guibg=" . s:nord2
exec "hi PmenuSel guifg=" . s:nord8 . " guibg=" . s:nord3
exec "hi PmenuSbar guibg=" . s:nord2
exec "hi PmenuThumb guibg=" . s:nord4
exec "hi IncSearch guifg=" . s:nord0 . " guibg=" . s:nord15
exec "hi Search guifg=" . s:nord0 . " guibg=" . s:nord15
exec "hi Directory guifg=" . s:nord11
exec "hi Folded guifg=" . s:nord4 . " guibg=" . s:nord1
exec "hi FoldColumn guifg=" . s:nord4 . " guibg=" . s:nord0
exec "hi WildMenu guifg=" . s:nord0 . " guibg=" . s:nord9
exec "hi TabLine guifg=" . s:nord6 . " guibg=" . s:nord2
exec "hi TabLineFill guifg=" . s:nord6 . " guibg=" . s:nord2
exec "hi TabLineSel guifg=" . s:nord8 . " guibg=" . s:nord3
exec "hi Visual guibg=" . s:nord3

" Syntax highlighting
exec "hi Comment guifg=" . s:nord4
exec "hi Constant guifg=" . s:nord15
exec "hi String guifg=" . s:nord16
exec "hi Character guifg=" . s:nord16
exec "hi Number guifg=" . s:nord15
exec "hi Boolean guifg=" . s:nord15
exec "hi Float guifg=" . s:nord15
exec "hi Identifier guifg=" . s:nord10
exec "hi Function guifg=" . s:nord11
exec "hi Statement guifg=" . s:nord12
exec "hi Conditional guifg=" . s:nord12
exec "hi Repeat guifg=" . s:nord12
exec "hi Label guifg=" . s:nord12
exec "hi Operator guifg=" . s:nord12
exec "hi Keyword guifg=" . s:nord12
exec "hi Exception guifg=" . s:nord12
exec "hi PreProc guifg=" . s:nord14
exec "hi Include guifg=" . s:nord14
exec "hi Define guifg=" . s:nord14
exec "hi Macro guifg=" . s:nord14
exec "hi PreCondit guifg=" . s:nord14
exec "hi Type guifg=" . s:nord9
exec "hi StorageClass guifg=" . s:nord9
exec "hi Structure guifg=" . s:nord9
exec "hi Typedef guifg=" . s:nord9
exec "hi Special guifg=" . s:nord17
exec "hi SpecialChar guifg=" . s:nord17
exec "hi Tag guifg=" . s:nord17
exec "hi Delimiter guifg=" . s:nord6
exec "hi SpecialComment guifg=" . s:nord4
exec "hi Debug guifg=" . s:nord17
exec "hi Underlined gui=underline"
exec "hi Error guifg=" . s:nord13 . " guibg=" . s:nord0
exec "hi Todo guifg=" . s:nord15 . " guibg=" . s:nord0 . " gui=bold"

" Git
exec "hi gitcommitSelectedFile guifg=" . s:nord16
exec "hi gitcommitDiscardedFile guifg=" . s:nord13

" Set terminal colors
if has('nvim')
  let g:terminal_color_0 = s:nord1
  let g:terminal_color_1 = s:nord13
  let g:terminal_color_2 = s:nord16
  let g:terminal_color_3 = s:nord15
  let g:terminal_color_4 = s:nord12
  let g:terminal_color_5 = s:nord17
  let g:terminal_color_6 = s:nord9
  let g:terminal_color_7 = s:nord6
  let g:terminal_color_8 = s:nord3
  let g:terminal_color_9 = s:nord13
  let g:terminal_color_10 = s:nord16
  let g:terminal_color_11 = s:nord15
  let g:terminal_color_12 = s:nord12
  let g:terminal_color_13 = s:nord17
  let g:terminal_color_14 = s:nord9
  let g:terminal_color_15 = s:nord8
endif 