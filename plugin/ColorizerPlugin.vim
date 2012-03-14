" Plugin:       Highlight Colornames and Values
" Maintainer:   Christian Brabandt <cb@256bit.org>
" URL:          http://www.github.com/chrisbra/color_highlight
" Last Change:  2012 Mar 02
" Licence:      No Warranties. Do whatever you want with this.
"               But please tell me!
" Version:      0.2
" GetLatestVimScripts: 3963 2 :AutoInstall: Colorizer.vim
"
" This plugin was inspired by the css_color.vim plugin from Nikolaus Hofer.
" Changes made: - make terminal colors work more reliably and with all
"                 color terminals
"               - performance improvements, coloring is almost instantenously
"               - detect rgb colors like this: rgb(R,G,B)
"               - detect hvl coloring: hvl(H,V,L)
"               - fix small bugs

" Init some variables "{{{1
" Plugin folklore "{{{2
if v:version < 700 || exists("g:loaded_colorizer") || &cp
  finish
endif
let g:loaded_colorizer = 1

let s:cpo_save = &cpo
set cpo&vim

" define commands "{{{1
command! -bang -range=%  ColorHighlight
        \ :call Colorizer#DoColor(<q-bang>, <q-line1>, <q-line2>)
command! -bang -nargs=1  RGB2Xterm  
        \ :call Colorizer#RGB2Term(<q-args>)

command! -bang    ColorClear  :call Colorizer#ColorOff()
command! -bang    ColorToggle :call Colorizer#ColorToggle()
command! -nargs=1 HSL2RGB     :echo Colorizer#ColorHSLValues(<q-args>)
command!          ColorContrast :call Colorizer#SwitchContrast()

" Plugin folklore and Vim Modeline " {{{1
let &cpo = s:cpo_save
unlet s:cpo_save
" vim: set foldmethod=marker et fdl=0:
