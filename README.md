Colorizer [![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/cb%40256bit.org)
=========
> A plugin to color colornames and codes

![screenshot of the plugin](screenshot.png "Screenshot")

This plugin is based on the css_color plugin by Nikolaus Hofer. The idea is to highlight color names and codes in the same color that they represent.

The plugin understands the W3-Colors (used for CSS files for example), the Color names from the X11 Window System and also codes in hex notation, like #FF0000 (which represents Red in the RGB color system). Additionally, it supports the CSS color specifications, e.g. rgb(RR,GG,BB) color representation in either absolute or percentage values and also the HVL Color representation like hvl(H,V,L).

It works best in the gui version of Vim, but the plugin also supports 256 and 88 color terminals and translates the colors to those supported by the terminal. 16 and 8 color terminals should work theoretically too, but hasn't been widely tested. Note, that translating the colors to the terminal might impose a performance penalty, depending on the terminal type and the number of matches in the file.

For terminals that are capable of displaying true colors, the plugin will also use true colors, if the ['termguicolors' option](http://vimhelp.appspot.com/options.txt.html#%27termguicolors%27) is set.

Also, it can highlight terminal color sequences correctly and will hide those terminal ansi sequences, so that the file can be read like it would be shown in the terminal. Here is a screen capture for coloring ANSI terminal sequences:
![Terminal Coloring](Colorizer.gif).

Installation
---

This plugin follows the standard runtime path structure, and as such it can be installed with a variety of plugin managers:

| Plugin Manager | Install with... |
| ------------- | ------------- |
| [Pathogen][1] | `git clone https://github.com/chrisbra/Colorizer ~/.vim/bundle/Colorizer `<br/>Remember to run `:Helptags` to generate help tags |
| [Vundle][2] | `Plugin 'chrisbra/Colorizer'` |
| [Plug][3] | `Plug 'chrisbra/Colorizer'` |
| [Dein][4] | `call dein#add('chrisbra/Colorizer')` |
| [minpac][5] | `call minpac#add('chrisbra/Colorizer')` |
| pack feature (native Vim 8 package feature)| `git clone https://github.com/chrisbra/Colorizer ~/.vim/pack/dist/start/Colorizer `<br/>Remember to run `:helptags ~/.vim/pack/dist/start/Colorizer/doc` to generate help tags |
| manual | copy all of the files into your `~/.vim` (Unix) or `~/vimfiles` (Windows) directory |


Usage
---
Once installed, take a look at the Colorizer help at `:h Colorizer`

License & Copyright
-------

Based on work by Nikolaus Hofer. Further developed by Christian Brabandt. 
The Vim License applies. See `:h license`

© 2009 - 2024 by Christian Brabandt

__NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK__

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/VundleVim/Vundle.vim
[3]: https://github.com/junegunn/vim-plug
[4]: https://github.com/Shougo/dein.vim
[5]: https://github.com/k-takata/minpac/
