" Plugin:       Highlight Colornames and Values
" Maintainer:   Christian Brabandt <cb@256bit.org>
" URL:          http://www.github.com/chrisbra/color_highlight
" Last Change: Wed, 25 Jul 2012 22:37:23 +0200
" Licence:      Vim License (see :h License)
" Version:      0.7
" GetLatestVimScripts: 3963 7 :AutoInstall: Colorizer.vim
"
" This plugin was inspired by the css_color.vim plugin from Nikolaus Hofer.
" Changes made: - make terminal colors work more reliably and with all
"                 color terminals
"               - performance improvements, coloring is almost instantenously
"               - detect rgb colors like this: rgb(R,G,B)
"               - detect hvl coloring: hvl(H,V,L)
"               - fix small bugs

" Init some variables "{{{1
let s:cpo_save = &cpo
set cpo&vim

" enable debug functions
let s:debug = 0

" the 6 value iterations in the xterm color cube "{{{2
let s:valuerange6 = [ 0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF ]

"" the 4 value iterations in the 88 color xterm cube "{{{2
let s:valuerange4 = [ 0x00, 0x8B, 0xCD, 0xFF ]
"
"" 16 basic colors "{{{2
let s:basic16 = [
    \ [ 0x00, 0x00, 0x00 ], 
    \ [ 0xCD, 0x00, 0x00 ], 
    \ [ 0x00, 0xCD, 0x00 ], 
    \ [ 0xCD, 0xCD, 0x00 ], 
    \ [ 0x00, 0x00, 0xEE ], 
    \ [ 0xCD, 0x00, 0xCD ], 
    \ [ 0x00, 0xCD, 0xCD ], 
    \ [ 0xE5, 0xE5, 0xE5 ], 
    \ [ 0x7F, 0x7F, 0x7F ], 
    \ [ 0xFF, 0x00, 0x00 ], 
    \ [ 0x00, 0xFF, 0x00 ], 
    \ [ 0xFF, 0xFF, 0x00 ], 
    \ [ 0x5C, 0x5C, 0xFF ], 
    \ [ 0xFF, 0x00, 0xFF ], 
    \ [ 0x00, 0xFF, 0xFF ], 
    \ [ 0xFF, 0xFF, 0xFF ]
    \ ]

" xterm-8 colors "{{{2
let s:xterm_8colors = {
\ 'black':          '#000000',
\ 'darkblue':       '#00008B',
\ 'darkgreen':      '#00CD00',
\ 'darkcyan':       '#00CDCD',
\ 'darkred':        '#CD0000',
\ 'darkmagenta':    '#8B008B',
\ 'brown':          '#CDCD00',
\ 'darkyellow':     '#CDCD00',
\ 'lightgrey':      '#E5E5E5',
\ 'lightgray':      '#E5E5E5',
\ 'gray':           '#E5E5E5',
\ 'grey':           '#E5E5E5'
\ }

" xterm-16 colors "{{{2
let s:xterm_16colors = {
\ 'darkgrey':       '#7F7F7F',
\ 'darkgray':       '#7F7F7F',
\ 'blue':           '#5C5CFF',
\ 'lightblue':      '#5C5CFF',
\ 'green':          '#00FF00',
\ 'lightgreen':     '#00FF00',
\ 'cyan':           '#00FFFF',
\ 'lightcyan':      '#00FFFF',
\ 'red':            '#FF0000',
\ 'lightred':       '#FF0000',
\ 'magenta':        '#FF00FF',
\ 'lightmagenta':   '#FF00FF',
\ 'yellow':         '#FFFF00',
\ 'lightyellow':    '#FFFF00',
\ 'white':          '#FFFFFF',
\ }
" add the items from the 8 color xterm variable to the 16 color xterm
call extend(s:xterm_16colors, s:xterm_8colors)

" W3C Colors "{{{2
let s:w3c_color_names = {
\ 'aliceblue': '#F0F8FF',
\ 'antiquewhite': '#FAEBD7',
\ 'aqua': '#00FFFF',
\ 'aquamarine': '#7FFFD4',
\ 'azure': '#F0FFFF',
\ 'beige': '#F5F5DC',
\ 'bisque': '#FFE4C4',
\ 'black': '#000000',
\ 'blanchedalmond': '#FFEBCD',
\ 'blue': '#0000FF',
\ 'blueviolet': '#8A2BE2',
\ 'brown': '#A52A2A',
\ 'burlywood': '#DEB887',
\ 'cadetblue': '#5F9EA0',
\ 'chartreuse': '#7FFF00',
\ 'chocolate': '#D2691E',
\ 'coral': '#FF7F50',
\ 'cornflowerblue': '#6495ED',
\ 'cornsilk': '#FFF8DC',
\ 'crimson': '#DC143C',
\ 'cyan': '#00FFFF',
\ 'darkblue': '#00008B',
\ 'darkcyan': '#008B8B',
\ 'darkgoldenrod': '#B8860B',
\ 'darkgray': '#A9A9A9',
\ 'darkgreen': '#006400',
\ 'darkkhaki': '#BDB76B',
\ 'darkmagenta': '#8B008B',
\ 'darkolivegreen': '#556B2F',
\ 'darkorange': '#FF8C00',
\ 'darkorchid': '#9932CC',
\ 'darkred': '#8B0000',
\ 'darksalmon': '#E9967A',
\ 'darkseagreen': '#8FBC8F',
\ 'darkslateblue': '#483D8B',
\ 'darkslategray': '#2F4F4F',
\ 'darkturquoise': '#00CED1',
\ 'darkviolet': '#9400D3',
\ 'deeppink': '#FF1493',
\ 'deepskyblue': '#00BFFF',
\ 'dimgray': '#696969',
\ 'dodgerblue': '#1E90FF',
\ 'firebrick': '#B22222',
\ 'floralwhite': '#FFFAF0',
\ 'forestgreen': '#228B22',
\ 'fuchsia': '#FF00FF',
\ 'gainsboro': '#DCDCDC',
\ 'ghostwhite': '#F8F8FF',
\ 'gold': '#FFD700',
\ 'goldenrod': '#DAA520',
\ 'gray': '#808080',
\ 'green': '#008000',
\ 'greenyellow': '#ADFF2F',
\ 'honeydew': '#F0FFF0',
\ 'hotpink': '#FF69B4',
\ 'indianred': '#CD5C5C',
\ 'indigo': '#4B0082',
\ 'ivory': '#FFFFF0',
\ 'khaki': '#F0E68C',
\ 'lavender': '#E6E6FA',
\ 'lavenderblush': '#FFF0F5',
\ 'lawngreen': '#7CFC00',
\ 'lemonchiffon': '#FFFACD',
\ 'lightblue': '#ADD8E6',
\ 'lightcoral': '#F08080',
\ 'lightcyan': '#E0FFFF',
\ 'lightgoldenrodyellow': '#FAFAD2',
\ 'lightgray': '#D3D3D3',
\ 'lightgreen': '#90EE90',
\ 'lightpink': '#FFB6C1',
\ 'lightsalmon': '#FFA07A',
\ 'lightseagreen': '#20B2AA',
\ 'lightskyblue': '#87CEFA',
\ 'lightslategray': '#778899',
\ 'lightsteelblue': '#B0C4DE',
\ 'lightyellow': '#FFFFE0',
\ 'lime': '#00FF00',
\ 'limegreen': '#32CD32',
\ 'linen': '#FAF0E6',
\ 'magenta': '#FF00FF',
\ 'maroon': '#800000',
\ 'mediumaquamarine': '#66CDAA',
\ 'mediumblue': '#0000CD',
\ 'mediumorchid': '#BA55D3',
\ 'mediumpurple': '#9370D8',
\ 'mediumseagreen': '#3CB371',
\ 'mediumslateblue': '#7B68EE',
\ 'mediumspringgreen': '#00FA9A',
\ 'mediumturquoise': '#48D1CC',
\ 'mediumvioletred': '#C71585',
\ 'midnightblue': '#191970',
\ 'mintcream': '#F5FFFA',
\ 'mistyrose': '#FFE4E1',
\ 'moccasin': '#FFE4B5',
\ 'navajowhite': '#FFDEAD',
\ 'navy': '#000080',
\ 'oldlace': '#FDF5E6',
\ 'olive': '#808000',
\ 'olivedrab': '#6B8E23',
\ 'orange': '#FFA500',
\ 'orangered': '#FF4500',
\ 'orchid': '#DA70D6',
\ 'palegoldenrod': '#EEE8AA',
\ 'palegreen': '#98FB98',
\ 'paleturquoise': '#AFEEEE',
\ 'palevioletred': '#D87093',
\ 'papayawhip': '#FFEFD5',
\ 'peachpuff': '#FFDAB9',
\ 'peru': '#CD853F',
\ 'pink': '#FFC0CB',
\ 'plum': '#DDA0DD',
\ 'powderblue': '#B0E0E6',
\ 'purple': '#800080',
\ 'red': '#FF0000',
\ 'rosybrown': '#BC8F8F',
\ 'royalblue': '#4169E1',
\ 'saddlebrown': '#8B4513',
\ 'salmon': '#FA8072',
\ 'sandybrown': '#F4A460',
\ 'seagreen': '#2E8B57',
\ 'seashell': '#FFF5EE',
\ 'sienna': '#A0522D',
\ 'silver': '#C0C0C0',
\ 'skyblue': '#87CEEB',
\ 'slateblue': '#6A5ACD',
\ 'slategray': '#708090',
\ 'snow': '#FFFAFA',
\ 'springgreen': '#00FF7F',
\ 'steelblue': '#4682B4',
\ 'tan': '#D2B48C',
\ 'teal': '#008080',
\ 'thistle': '#D8BFD8',
\ 'tomato': '#FF6347',
\ 'turquoise': '#40E0D0',
\ 'violet': '#EE82EE',
\ 'wheat': '#F5DEB3',
\ 'white': '#FFFFFF',
\ 'whitesmoke': '#F5F5F5',
\ 'yellow': '#FFFF00',
\ 'yellowgreen': '#9ACD32'
\ }

" X11 color names taken from "{{{2
" http://cvsweb.xfree86.org/cvsweb/*checkout*/xc/programs/rgb/rgb.txt?rev=1.2
let s:x11_color_names = {
\ 'snow': '#FFFAFA',
\ 'ghostwhite': '#F8F8FF',
\ 'whitesmoke': '#F5F5F5',
\ 'gainsboro': '#DCDCDC',
\ 'floralwhite': '#FFFAF0',
\ 'oldlace': '#FDF5E6',
\ 'linen': '#FAF0E6',
\ 'antiquewhite': '#FAEBD7',
\ 'papayawhip': '#FFEFD5',
\ 'blanchedalmond': '#FFEBCD',
\ 'bisque': '#FFE4C4',
\ 'peachpuff': '#FFDAB9',
\ 'navajowhite': '#FFDEAD',
\ 'moccasin': '#FFE4B5',
\ 'cornsilk': '#FFF8DC',
\ 'ivory': '#FFFFF0',
\ 'lemonchiffon': '#FFFACD',
\ 'seashell': '#FFF5EE',
\ 'honeydew': '#F0FFF0',
\ 'mintcream': '#F5FFFA',
\ 'azure': '#F0FFFF',
\ 'aliceblue': '#F0F8FF',
\ 'lavender': '#E6E6FA',
\ 'lavenderblush': '#FFF0F5',
\ 'mistyrose': '#FFE4E1',
\ 'white': '#FFFFFF',
\ 'black': '#000000',
\ 'darkslategray': '#2F4F4F',
\ 'darkslategrey': '#2F4F4F',
\ 'dimgray': '#696969',
\ 'dimgrey': '#696969',
\ 'slategray': '#708090',
\ 'slategrey': '#708090',
\ 'lightslategray': '#778899',
\ 'lightslategrey': '#778899',
\ 'gray': '#BEBEBE',
\ 'grey': '#BEBEBE',
\ 'lightgrey': '#D3D3D3',
\ 'lightgray': '#D3D3D3',
\ 'midnightblue': '#191970',
\ 'navy': '#000080',
\ 'navyblue': '#000080',
\ 'cornflowerblue': '#6495ED',
\ 'darkslateblue': '#483D8B',
\ 'slateblue': '#6A5ACD',
\ 'mediumslateblue': '#7B68EE',
\ 'lightslateblue': '#8470FF',
\ 'mediumblue': '#0000CD',
\ 'royalblue': '#4169E1',
\ 'blue': '#0000FF',
\ 'dodgerblue': '#1E90FF',
\ 'deepskyblue': '#00BFFF',
\ 'skyblue': '#87CEEB',
\ 'lightskyblue': '#87CEFA',
\ 'steelblue': '#4682B4',
\ 'lightsteelblue': '#B0C4DE',
\ 'lightblue': '#ADD8E6',
\ 'powderblue': '#B0E0E6',
\ 'paleturquoise': '#AFEEEE',
\ 'darkturquoise': '#00CED1',
\ 'mediumturquoise': '#48D1CC',
\ 'turquoise': '#40E0D0',
\ 'cyan': '#00FFFF',
\ 'lightcyan': '#E0FFFF',
\ 'cadetblue': '#5F9EA0',
\ 'mediumaquamarine': '#66CDAA',
\ 'aquamarine': '#7FFFD4',
\ 'darkgreen': '#006400',
\ 'darkolivegreen': '#556B2F',
\ 'darkseagreen': '#8FBC8F',
\ 'seagreen': '#2E8B57',
\ 'mediumseagreen': '#3CB371',
\ 'lightseagreen': '#20B2AA',
\ 'palegreen': '#98FB98',
\ 'springgreen': '#00FF7F',
\ 'lawngreen': '#7CFC00',
\ 'green': '#00FF00',
\ 'chartreuse': '#7FFF00',
\ 'mediumspringgreen': '#00FA9A',
\ 'greenyellow': '#ADFF2F',
\ 'limegreen': '#32CD32',
\ 'yellowgreen': '#9ACD32',
\ 'forestgreen': '#228B22',
\ 'olivedrab': '#6B8E23',
\ 'darkkhaki': '#BDB76B',
\ 'khaki': '#F0E68C',
\ 'palegoldenrod': '#EEE8AA',
\ 'lightgoldenrodyellow': '#FAFAD2',
\ 'lightyellow': '#FFFFE0',
\ 'yellow': '#FFFF00',
\ 'gold': '#FFD700',
\ 'lightgoldenrod': '#EEDD82',
\ 'goldenrod': '#DAA520',
\ 'darkgoldenrod': '#B8860B',
\ 'rosybrown': '#BC8F8F',
\ 'indianred': '#CD5C5C',
\ 'saddlebrown': '#8B4513',
\ 'sienna': '#A0522D',
\ 'peru': '#CD853F',
\ 'burlywood': '#DEB887',
\ 'beige': '#F5F5DC',
\ 'wheat': '#F5DEB3',
\ 'sandybrown': '#F4A460',
\ 'tan': '#D2B48C',
\ 'chocolate': '#D2691E',
\ 'firebrick': '#B22222',
\ 'brown': '#A52A2A',
\ 'darksalmon': '#E9967A',
\ 'salmon': '#FA8072',
\ 'lightsalmon': '#FFA07A',
\ 'orange': '#FFA500',
\ 'darkorange': '#FF8C00',
\ 'coral': '#FF7F50',
\ 'lightcoral': '#F08080',
\ 'tomato': '#FF6347',
\ 'orangered': '#FF4500',
\ 'red': '#FF0000',
\ 'hotpink': '#FF69B4',
\ 'deeppink': '#FF1493',
\ 'pink': '#FFC0CB',
\ 'lightpink': '#FFB6C1',
\ 'palevioletred': '#DB7093',
\ 'maroon': '#B03060',
\ 'mediumvioletred': '#C71585',
\ 'violetred': '#D02090',
\ 'magenta': '#FF00FF',
\ 'violet': '#EE82EE',
\ 'plum': '#DDA0DD',
\ 'orchid': '#DA70D6',
\ 'mediumorchid': '#BA55D3',
\ 'darkorchid': '#9932CC',
\ 'darkviolet': '#9400D3',
\ 'blueviolet': '#8A2BE2',
\ 'purple': '#A020F0',
\ 'mediumpurple': '#9370DB',
\ 'thistle': '#D8BFD8',
\ 'snow1': '#FFFAFA',
\ 'snow2': '#EEE9E9',
\ 'snow3': '#CDC9C9',
\ 'snow4': '#8B8989',
\ 'seashell1': '#FFF5EE',
\ 'seashell2': '#EEE5DE',
\ 'seashell3': '#CDC5BF',
\ 'seashell4': '#8B8682',
\ 'antiquewhite1': '#FFEFDB',
\ 'antiquewhite2': '#EEDFCC',
\ 'antiquewhite3': '#CDC0B0',
\ 'antiquewhite4': '#8B8378',
\ 'bisque1': '#FFE4C4',
\ 'bisque2': '#EED5B7',
\ 'bisque3': '#CDB79E',
\ 'bisque4': '#8B7D6B',
\ 'peachpuff1': '#FFDAB9',
\ 'peachpuff2': '#EECBAD',
\ 'peachpuff3': '#CDAF95',
\ 'peachpuff4': '#8B7765',
\ 'navajowhite1': '#FFDEAD',
\ 'navajowhite2': '#EECFA1',
\ 'navajowhite3': '#CDB38B',
\ 'navajowhite4': '#8B795E',
\ 'lemonchiffon1': '#FFFACD',
\ 'lemonchiffon2': '#EEE9BF',
\ 'lemonchiffon3': '#CDC9A5',
\ 'lemonchiffon4': '#8B8970',
\ 'cornsilk1': '#FFF8DC',
\ 'cornsilk2': '#EEE8CD',
\ 'cornsilk3': '#CDC8B1',
\ 'cornsilk4': '#8B8878',
\ 'ivory1': '#FFFFF0',
\ 'ivory2': '#EEEEE0',
\ 'ivory3': '#CDCDC1',
\ 'ivory4': '#8B8B83',
\ 'honeydew1': '#F0FFF0',
\ 'honeydew2': '#E0EEE0',
\ 'honeydew3': '#C1CDC1',
\ 'honeydew4': '#838B83',
\ 'lavenderblush1': '#FFF0F5',
\ 'lavenderblush2': '#EEE0E5',
\ 'lavenderblush3': '#CDC1C5',
\ 'lavenderblush4': '#8B8386',
\ 'mistyrose1': '#FFE4E1',
\ 'mistyrose2': '#EED5D2',
\ 'mistyrose3': '#CDB7B5',
\ 'mistyrose4': '#8B7D7B',
\ 'azure1': '#F0FFFF',
\ 'azure2': '#E0EEEE',
\ 'azure3': '#C1CDCD',
\ 'azure4': '#838B8B',
\ 'slateblue1': '#836FFF',
\ 'slateblue2': '#7A67EE',
\ 'slateblue3': '#6959CD',
\ 'slateblue4': '#473C8B',
\ 'royalblue1': '#4876FF',
\ 'royalblue2': '#436EEE',
\ 'royalblue3': '#3A5FCD',
\ 'royalblue4': '#27408B',
\ 'blue1': '#0000FF',
\ 'blue2': '#0000EE',
\ 'blue3': '#0000CD',
\ 'blue4': '#00008B',
\ 'dodgerblue1': '#1E90FF',
\ 'dodgerblue2': '#1C86EE',
\ 'dodgerblue3': '#1874CD',
\ 'dodgerblue4': '#104E8B',
\ 'steelblue1': '#63B8FF',
\ 'steelblue2': '#5CACEE',
\ 'steelblue3': '#4F94CD',
\ 'steelblue4': '#36648B',
\ 'deepskyblue1': '#00BFFF',
\ 'deepskyblue2': '#00B2EE',
\ 'deepskyblue3': '#009ACD',
\ 'deepskyblue4': '#00688B',
\ 'skyblue1': '#87CEFF',
\ 'skyblue2': '#7EC0EE',
\ 'skyblue3': '#6CA6CD',
\ 'skyblue4': '#4A708B',
\ 'lightskyblue1': '#B0E2FF',
\ 'lightskyblue2': '#A4D3EE',
\ 'lightskyblue3': '#8DB6CD',
\ 'lightskyblue4': '#607B8B',
\ 'slategray1': '#C6E2FF',
\ 'slategray2': '#B9D3EE',
\ 'slategray3': '#9FB6CD',
\ 'slategray4': '#6C7B8B',
\ 'lightsteelblue1': '#CAE1FF',
\ 'lightsteelblue2': '#BCD2EE',
\ 'lightsteelblue3': '#A2B5CD',
\ 'lightsteelblue4': '#6E7B8B',
\ 'lightblue1': '#BFEFFF',
\ 'lightblue2': '#B2DFEE',
\ 'lightblue3': '#9AC0CD',
\ 'lightblue4': '#68838B',
\ 'lightcyan1': '#E0FFFF',
\ 'lightcyan2': '#D1EEEE',
\ 'lightcyan3': '#B4CDCD',
\ 'lightcyan4': '#7A8B8B',
\ 'paleturquoise1': '#BBFFFF',
\ 'paleturquoise2': '#AEEEEE',
\ 'paleturquoise3': '#96CDCD',
\ 'paleturquoise4': '#668B8B',
\ 'cadetblue1': '#98F5FF',
\ 'cadetblue2': '#8EE5EE',
\ 'cadetblue3': '#7AC5CD',
\ 'cadetblue4': '#53868B',
\ 'turquoise1': '#00F5FF',
\ 'turquoise2': '#00E5EE',
\ 'turquoise3': '#00C5CD',
\ 'turquoise4': '#00868B',
\ 'cyan1': '#00FFFF',
\ 'cyan2': '#00EEEE',
\ 'cyan3': '#00CDCD',
\ 'cyan4': '#008B8B',
\ 'darkslategray1': '#97FFFF',
\ 'darkslategray2': '#8DEEEE',
\ 'darkslategray3': '#79CDCD',
\ 'darkslategray4': '#528B8B',
\ 'aquamarine1': '#7FFFD4',
\ 'aquamarine2': '#76EEC6',
\ 'aquamarine3': '#66CDAA',
\ 'aquamarine4': '#458B74',
\ 'darkseagreen1': '#C1FFC1',
\ 'darkseagreen2': '#B4EEB4',
\ 'darkseagreen3': '#9BCD9B',
\ 'darkseagreen4': '#698B69',
\ 'seagreen1': '#54FF9F',
\ 'seagreen2': '#4EEE94',
\ 'seagreen3': '#43CD80',
\ 'seagreen4': '#2E8B57',
\ 'palegreen1': '#9AFF9A',
\ 'palegreen2': '#90EE90',
\ 'palegreen3': '#7CCD7C',
\ 'palegreen4': '#548B54',
\ 'springgreen1': '#00FF7F',
\ 'springgreen2': '#00EE76',
\ 'springgreen3': '#00CD66',
\ 'springgreen4': '#008B45',
\ 'green1': '#00FF00',
\ 'green2': '#00EE00',
\ 'green3': '#00CD00',
\ 'green4': '#008B00',
\ 'chartreuse1': '#7FFF00',
\ 'chartreuse2': '#76EE00',
\ 'chartreuse3': '#66CD00',
\ 'chartreuse4': '#458B00',
\ 'olivedrab1': '#C0FF3E',
\ 'olivedrab2': '#B3EE3A',
\ 'olivedrab3': '#9ACD32',
\ 'olivedrab4': '#698B22',
\ 'darkolivegreen1': '#CAFF70',
\ 'darkolivegreen2': '#BCEE68',
\ 'darkolivegreen3': '#A2CD5A',
\ 'darkolivegreen4': '#6E8B3D',
\ 'khaki1': '#FFF68F',
\ 'khaki2': '#EEE685',
\ 'khaki3': '#CDC673',
\ 'khaki4': '#8B864E',
\ 'lightgoldenrod1': '#FFEC8B',
\ 'lightgoldenrod2': '#EEDC82',
\ 'lightgoldenrod3': '#CDBE70',
\ 'lightgoldenrod4': '#8B814C',
\ 'lightyellow1': '#FFFFE0',
\ 'lightyellow2': '#EEEED1',
\ 'lightyellow3': '#CDCDB4',
\ 'lightyellow4': '#8B8B7A',
\ 'yellow1': '#FFFF00',
\ 'yellow2': '#EEEE00',
\ 'yellow3': '#CDCD00',
\ 'yellow4': '#8B8B00',
\ 'gold1': '#FFD700',
\ 'gold2': '#EEC900',
\ 'gold3': '#CDAD00',
\ 'gold4': '#8B7500',
\ 'goldenrod1': '#FFC125',
\ 'goldenrod2': '#EEB422',
\ 'goldenrod3': '#CD9B1D',
\ 'goldenrod4': '#8B6914',
\ 'darkgoldenrod1': '#FFB90F',
\ 'darkgoldenrod2': '#EEAD0E',
\ 'darkgoldenrod3': '#CD950C',
\ 'darkgoldenrod4': '#8B6508',
\ 'rosybrown1': '#FFC1C1',
\ 'rosybrown2': '#EEB4B4',
\ 'rosybrown3': '#CD9B9B',
\ 'rosybrown4': '#8B6969',
\ 'indianred1': '#FF6A6A',
\ 'indianred2': '#EE6363',
\ 'indianred3': '#CD5555',
\ 'indianred4': '#8B3A3A',
\ 'sienna1': '#FF8247',
\ 'sienna2': '#EE7942',
\ 'sienna3': '#CD6839',
\ 'sienna4': '#8B4726',
\ 'burlywood1': '#FFD39B',
\ 'burlywood2': '#EEC591',
\ 'burlywood3': '#CDAA7D',
\ 'burlywood4': '#8B7355',
\ 'wheat1': '#FFE7BA',
\ 'wheat2': '#EED8AE',
\ 'wheat3': '#CDBA96',
\ 'wheat4': '#8B7E66',
\ 'tan1': '#FFA54F',
\ 'tan2': '#EE9A49',
\ 'tan3': '#CD853F',
\ 'tan4': '#8B5A2B',
\ 'chocolate1': '#FF7F24',
\ 'chocolate2': '#EE7621',
\ 'chocolate3': '#CD661D',
\ 'chocolate4': '#8B4513',
\ 'firebrick1': '#FF3030',
\ 'firebrick2': '#EE2C2C',
\ 'firebrick3': '#CD2626',
\ 'firebrick4': '#8B1A1A',
\ 'brown1': '#FF4040',
\ 'brown2': '#EE3B3B',
\ 'brown3': '#CD3333',
\ 'brown4': '#8B2323',
\ 'salmon1': '#FF8C69',
\ 'salmon2': '#EE8262',
\ 'salmon3': '#CD7054',
\ 'salmon4': '#8B4C39',
\ 'lightsalmon1': '#FFA07A',
\ 'lightsalmon2': '#EE9572',
\ 'lightsalmon3': '#CD8162',
\ 'lightsalmon4': '#8B5742',
\ 'orange1': '#FFA500',
\ 'orange2': '#EE9A00',
\ 'orange3': '#CD8500',
\ 'orange4': '#8B5A00',
\ 'darkorange1': '#FF7F00',
\ 'darkorange2': '#EE7600',
\ 'darkorange3': '#CD6600',
\ 'darkorange4': '#8B4500',
\ 'coral1': '#FF7256',
\ 'coral2': '#EE6A50',
\ 'coral3': '#CD5B45',
\ 'coral4': '#8B3E2F',
\ 'tomato1': '#FF6347',
\ 'tomato2': '#EE5C42',
\ 'tomato3': '#CD4F39',
\ 'tomato4': '#8B3626',
\ 'orangered1': '#FF4500',
\ 'orangered2': '#EE4000',
\ 'orangered3': '#CD3700',
\ 'orangered4': '#8B2500',
\ 'red1': '#FF0000',
\ 'red2': '#EE0000',
\ 'red3': '#CD0000',
\ 'red4': '#8B0000',
\ 'deeppink1': '#FF1493',
\ 'deeppink2': '#EE1289',
\ 'deeppink3': '#CD1076',
\ 'deeppink4': '#8B0A50',
\ 'hotpink1': '#FF6EB4',
\ 'hotpink2': '#EE6AA7',
\ 'hotpink3': '#CD6090',
\ 'hotpink4': '#8B3A62',
\ 'pink1': '#FFB5C5',
\ 'pink2': '#EEA9B8',
\ 'pink3': '#CD919E',
\ 'pink4': '#8B636C',
\ 'lightpink1': '#FFAEB9',
\ 'lightpink2': '#EEA2AD',
\ 'lightpink3': '#CD8C95',
\ 'lightpink4': '#8B5F65',
\ 'palevioletred1': '#FF82AB',
\ 'palevioletred2': '#EE799F',
\ 'palevioletred3': '#CD6889',
\ 'palevioletred4': '#8B475D',
\ 'maroon1': '#FF34B3',
\ 'maroon2': '#EE30A7',
\ 'maroon3': '#CD2990',
\ 'maroon4': '#8B1C62',
\ 'violetred1': '#FF3E96',
\ 'violetred2': '#EE3A8C',
\ 'violetred3': '#CD3278',
\ 'violetred4': '#8B2252',
\ 'magenta1': '#FF00FF',
\ 'magenta2': '#EE00EE',
\ 'magenta3': '#CD00CD',
\ 'magenta4': '#8B008B',
\ 'orchid1': '#FF83FA',
\ 'orchid2': '#EE7AE9',
\ 'orchid3': '#CD69C9',
\ 'orchid4': '#8B4789',
\ 'plum1': '#FFBBFF',
\ 'plum2': '#EEAEEE',
\ 'plum3': '#CD96CD',
\ 'plum4': '#8B668B',
\ 'mediumorchid1': '#E066FF',
\ 'mediumorchid2': '#D15FEE',
\ 'mediumorchid3': '#B452CD',
\ 'mediumorchid4': '#7A378B',
\ 'darkorchid1': '#BF3EFF',
\ 'darkorchid2': '#B23AEE',
\ 'darkorchid3': '#9A32CD',
\ 'darkorchid4': '#68228B',
\ 'purple1': '#9B30FF',
\ 'purple2': '#912CEE',
\ 'purple3': '#7D26CD',
\ 'purple4': '#551A8B',
\ 'mediumpurple1': '#AB82FF',
\ 'mediumpurple2': '#9F79EE',
\ 'mediumpurple3': '#8968CD',
\ 'mediumpurple4': '#5D478B',
\ 'thistle1': '#FFE1FF',
\ 'thistle2': '#EED2EE',
\ 'thistle3': '#CDB5CD',
\ 'thistle4': '#8B7B8B',
\ 'gray0': '#000000',
\ 'grey0': '#000000',
\ 'gray1': '#030303',
\ 'grey1': '#030303',
\ 'gray2': '#050505',
\ 'grey2': '#050505',
\ 'gray3': '#080808',
\ 'grey3': '#080808',
\ 'gray4': '#0A0A0A',
\ 'grey4': '#0A0A0A',
\ 'gray5': '#0D0D0D',
\ 'grey5': '#0D0D0D',
\ 'gray6': '#0F0F0F',
\ 'grey6': '#0F0F0F',
\ 'gray7': '#121212',
\ 'grey7': '#121212',
\ 'gray8': '#141414',
\ 'grey8': '#141414',
\ 'gray9': '#171717',
\ 'grey9': '#171717',
\ 'gray10': '#1A1A1A',
\ 'grey10': '#1A1A1A',
\ 'gray11': '#1C1C1C',
\ 'grey11': '#1C1C1C',
\ 'gray12': '#1F1F1F',
\ 'grey12': '#1F1F1F',
\ 'gray13': '#212121',
\ 'grey13': '#212121',
\ 'gray14': '#242424',
\ 'grey14': '#242424',
\ 'gray15': '#262626',
\ 'grey15': '#262626',
\ 'gray16': '#292929',
\ 'grey16': '#292929',
\ 'gray17': '#2B2B2B',
\ 'grey17': '#2B2B2B',
\ 'gray18': '#2E2E2E',
\ 'grey18': '#2E2E2E',
\ 'gray19': '#303030',
\ 'grey19': '#303030',
\ 'gray20': '#333333',
\ 'grey20': '#333333',
\ 'gray21': '#363636',
\ 'grey21': '#363636',
\ 'gray22': '#383838',
\ 'grey22': '#383838',
\ 'gray23': '#3B3B3B',
\ 'grey23': '#3B3B3B',
\ 'gray24': '#3D3D3D',
\ 'grey24': '#3D3D3D',
\ 'gray25': '#404040',
\ 'grey25': '#404040',
\ 'gray26': '#424242',
\ 'grey26': '#424242',
\ 'gray27': '#454545',
\ 'grey27': '#454545',
\ 'gray28': '#474747',
\ 'grey28': '#474747',
\ 'gray29': '#4A4A4A',
\ 'grey29': '#4A4A4A',
\ 'gray30': '#4D4D4D',
\ 'grey30': '#4D4D4D',
\ 'gray31': '#4F4F4F',
\ 'grey31': '#4F4F4F',
\ 'gray32': '#525252',
\ 'grey32': '#525252',
\ 'gray33': '#545454',
\ 'grey33': '#545454',
\ 'gray34': '#575757',
\ 'grey34': '#575757',
\ 'gray35': '#595959',
\ 'grey35': '#595959',
\ 'gray36': '#5C5C5C',
\ 'grey36': '#5C5C5C',
\ 'gray37': '#5E5E5E',
\ 'grey37': '#5E5E5E',
\ 'gray38': '#616161',
\ 'grey38': '#616161',
\ 'gray39': '#636363',
\ 'grey39': '#636363',
\ 'gray40': '#666666',
\ 'grey40': '#666666',
\ 'gray41': '#696969',
\ 'grey41': '#696969',
\ 'gray42': '#6B6B6B',
\ 'grey42': '#6B6B6B',
\ 'gray43': '#6E6E6E',
\ 'grey43': '#6E6E6E',
\ 'gray44': '#707070',
\ 'grey44': '#707070',
\ 'gray45': '#737373',
\ 'grey45': '#737373',
\ 'gray46': '#757575',
\ 'grey46': '#757575',
\ 'gray47': '#787878',
\ 'grey47': '#787878',
\ 'gray48': '#7A7A7A',
\ 'grey48': '#7A7A7A',
\ 'gray49': '#7D7D7D',
\ 'grey49': '#7D7D7D',
\ 'gray50': '#7F7F7F',
\ 'grey50': '#7F7F7F',
\ 'gray51': '#828282',
\ 'grey51': '#828282',
\ 'gray52': '#858585',
\ 'grey52': '#858585',
\ 'gray53': '#878787',
\ 'grey53': '#878787',
\ 'gray54': '#8A8A8A',
\ 'grey54': '#8A8A8A',
\ 'gray55': '#8C8C8C',
\ 'grey55': '#8C8C8C',
\ 'gray56': '#8F8F8F',
\ 'grey56': '#8F8F8F',
\ 'gray57': '#919191',
\ 'grey57': '#919191',
\ 'gray58': '#949494',
\ 'grey58': '#949494',
\ 'gray59': '#969696',
\ 'grey59': '#969696',
\ 'gray60': '#999999',
\ 'grey60': '#999999',
\ 'gray61': '#9C9C9C',
\ 'grey61': '#9C9C9C',
\ 'gray62': '#9E9E9E',
\ 'grey62': '#9E9E9E',
\ 'gray63': '#A1A1A1',
\ 'grey63': '#A1A1A1',
\ 'gray64': '#A3A3A3',
\ 'grey64': '#A3A3A3',
\ 'gray65': '#A6A6A6',
\ 'grey65': '#A6A6A6',
\ 'gray66': '#A8A8A8',
\ 'grey66': '#A8A8A8',
\ 'gray67': '#ABABAB',
\ 'grey67': '#ABABAB',
\ 'gray68': '#ADADAD',
\ 'grey68': '#ADADAD',
\ 'gray69': '#B0B0B0',
\ 'grey69': '#B0B0B0',
\ 'gray70': '#B3B3B3',
\ 'grey70': '#B3B3B3',
\ 'gray71': '#B5B5B5',
\ 'grey71': '#B5B5B5',
\ 'gray72': '#B8B8B8',
\ 'grey72': '#B8B8B8',
\ 'gray73': '#BABABA',
\ 'grey73': '#BABABA',
\ 'gray74': '#BDBDBD',
\ 'grey74': '#BDBDBD',
\ 'gray75': '#BFBFBF',
\ 'grey75': '#BFBFBF',
\ 'gray76': '#C2C2C2',
\ 'grey76': '#C2C2C2',
\ 'gray77': '#C4C4C4',
\ 'grey77': '#C4C4C4',
\ 'gray78': '#C7C7C7',
\ 'grey78': '#C7C7C7',
\ 'gray79': '#C9C9C9',
\ 'grey79': '#C9C9C9',
\ 'gray80': '#CCCCCC',
\ 'grey80': '#CCCCCC',
\ 'gray81': '#CFCFCF',
\ 'grey81': '#CFCFCF',
\ 'gray82': '#D1D1D1',
\ 'grey82': '#D1D1D1',
\ 'gray83': '#D4D4D4',
\ 'grey83': '#D4D4D4',
\ 'gray84': '#D6D6D6',
\ 'grey84': '#D6D6D6',
\ 'gray85': '#D9D9D9',
\ 'grey85': '#D9D9D9',
\ 'gray86': '#DBDBDB',
\ 'grey86': '#DBDBDB',
\ 'gray87': '#DEDEDE',
\ 'grey87': '#DEDEDE',
\ 'gray88': '#E0E0E0',
\ 'grey88': '#E0E0E0',
\ 'gray89': '#E3E3E3',
\ 'grey89': '#E3E3E3',
\ 'gray90': '#E5E5E5',
\ 'grey90': '#E5E5E5',
\ 'gray91': '#E8E8E8',
\ 'grey91': '#E8E8E8',
\ 'gray92': '#EBEBEB',
\ 'grey92': '#EBEBEB',
\ 'gray93': '#EDEDED',
\ 'grey93': '#EDEDED',
\ 'gray94': '#F0F0F0',
\ 'grey94': '#F0F0F0',
\ 'gray95': '#F2F2F2',
\ 'grey95': '#F2F2F2',
\ 'gray96': '#F5F5F5',
\ 'grey96': '#F5F5F5',
\ 'gray97': '#F7F7F7',
\ 'grey97': '#F7F7F7',
\ 'gray98': '#FAFAFA',
\ 'grey98': '#FAFAFA',
\ 'gray99': '#FCFCFC',
\ 'grey99': '#FCFCFC',
\ 'gray100': '#FFFFFF',
\ 'grey100': '#FFFFFF',
\ 'darkgrey': '#A9A9A9',
\ 'darkgray': '#A9A9A9',
\ 'darkblue': '#00008B',
\ 'darkcyan': '#008B8B',
\ 'darkmagenta': '#8B008B',
\ 'darkred': '#8B0000',
\ 'lightgreen': '#90EE90'
\ }

function! s:FGforBG(bg) "{{{1
   " takes a 6hex color code and returns a matching color that is visible
   let fgc = g:colorizer_fgcontrast
   let pure = a:bg
   let r = '0x'.pure[0:1]+0
   let g = '0x'.pure[2:3]+0
   let b = '0x'.pure[4:5]+0
   if r*30 + g*59 + b*11 > 12000
        return s:predefined_fgcolors['dark'][fgc]
    else
        return s:predefined_fgcolors['light'][fgc]
   end
endfunction

function! s:DidColor(clr, pat) "{{{1
    let idx = index(s:match_list, a:pat)
    if idx > -1
        if a:pat[0] == '#' ||
        \ !empty(synIDattr(hlID(a:clr), 'fg'))
            return 1
        endif
    endif
    return 0
endfu

function! s:DoHlGroup(clr) "{{{1
    let group = 'Color_'. a:clr
    if !s:force_hl 
        let syn = synIDattr(hlID(group), 'fg')
        if !empty(syn) && syn > -1
            " highlighting already exists
            return
        endif
    endif
    let clr = a:clr
    let bg  = clr
    let fg = g:colorizer_fgcontrast < 0 ? clr : s:FGforBG(a:clr)
    if s:swap_fg_bg > 0
        let fg  = clr
        let bg  = 'NONE'
    elseif s:swap_fg_bg == -1
        let t   = fg
        let fg  = clr
        let bg  = t
        unlet t
    endif
    let hi  = printf('hi %s guifg=#%s', group, fg)
    let hi .= printf(' guibg=%s', (bg != 'NONE' ? '#'.bg : bg))
    if !has("gui_running")
        let fg = s:Rgb2xterm(fg)
        let bg = bg != 'NONE' ? s:Rgb2xterm(bg) : bg
	let hi.= printf(' ctermfg=%s ctermbg=%s', fg, bg)
    endif
    "Don't error out for invalid colors
    try 
        exe hi
    catch 
        " Only report errors, when debugging info is turned on
        if s:debug
            call s:Warn("Invalid color: ".hi)
        endif
    endtry
endfunction

function! s:SetMatcher(clr, pattern) "{{{1
    let clr = 'Color_'. a:clr
    call s:DoHlGroup(a:clr)
    if s:DidColor(clr, a:pattern)
        return
    endif
    " let 'hls' overrule our syntax highlighting
    call matchadd(clr, a:pattern, -1)
    call add(s:match_list, a:pattern)
endfunction

function! s:Xterm2rgb16(color) "{{{1
        " 16 basic colors
    let r=0
    let g=0
    let b=0
    let r = s:basic16[a:color][0]
    let g = s:basic16[a:color][1]
    let b = s:basic16[a:color][2]
    return [ r, g, b ]
endfunction

function! s:Xterm2rgb88(color) "{{{1
    " 16 basic colors
    let r=0
    let g=0
    let b=0
    if a:color < 16
       return s:Xterm2rgb16(a:color)

    " 4x4x4 color cube
    elseif a:color >= 16 && a:color < 80
        let color=a:color-16
        let r = s:valuerange4[(color/16)%4]
        let g = s:valuerange4[(color/4)%4]
        let b = s:valuerange4[color%4]
    " gray tone
    elseif a:color >= 80 && a:color <= 87
      let color = (a:color-80) + 0.0
      let r = 46.36363636 + color * 23.18181818 +
            \ (color > 0.0 ? 23.18181818 : 0.0) +  0.0
      let r = float2nr(r)
      let g = r
      let b = r
   endif

    let rgb=[r,g,b]
    return rgb
endfunction

function! s:Xterm2rgb256(color)  "{{{1
    " 16 basic colors
   let r=0
   let g=0
   let b=0
   if a:color < 16
       return s:Xterm2rgb16(a:color)

    " color cube color
    elseif a:color >= 16 && a:color < 232
      let color=a:color-16
      let r = s:valuerange6[(color/36)%6]
      let g = s:valuerange6[(color/6)%6]
      let b = s:valuerange6[color%6]

    " gray tone
    elseif a:color >= 232 && a:color <= 255
      let r = 8 + (a:color-232) * 0x0a
      let g = r
      let b = r
   endif
   let rgb=[r,g,b]
   return rgb
endfunction

function! s:RoundColor(...) "{{{1
    let result = []
    let minlist = []
    let min    = 1000
    let list = (&t_Co == 256 ? s:valuerange6 : s:valuerange4)
    if &t_Co > 16
        for item in a:000
            for val in list
                let t = abs(val - item)
                if (min > t)
                    let min = t
                    let r   = val
                endif
            endfor
            call add(result, r)
            call add(minlist, min)
            let min = 1000
        endfor
    endif
    if &t_Co <= 16
        let result  = [ a:1, a:2, a:3 ]
        let minlist = [ 255, 255, 255 ]
    endif
    " Check with the values from the 16 color xterm, if the difference
    " is lower
    let result = s:Check16ColorTerm(result, minlist)

    return result
endfunction

function! s:Check16ColorTerm(rgblist, minlist) "{{{1
" We only check those values for 256 color terminals here:
" [205,0,0] [0,205,0] [205,205,0] [205,0,205]
" [0,205,205] [0,0,238] [92,92,255]
" The other values are already included in the s:colortable list
    let min = a:minlist[0] + a:minlist[1] + a:minlist[2]
    if &t_Co == 256
        for value in [[205,0,0], [0,205,0], [205,205,0], [205,0,205],
                \ [0,205,205], [0,0,238], [92,92,255]]
            " euclidian distance would be needed,
            " but this works good enough and is faster.
            let t = abs(value[0] - a:rgblist[0]) +
                    \ abs(value[1] - a:rgblist[1]) +
                    \ abs(value[2] - a:rgblist[2])
            if min > t
                return value
            endif
        endfor
    elseif &t_Co == 88
        for value in [[0,0,238], [229,229,229], [127,127,127], [92,92,255]]
            let t = abs(value[0] - a:rgblist[0]) +
                    \ abs(value[1] - a:rgblist[1]) +
                    \ abs(value[2] - a:rgblist[2])
            if min > t
                return value
            endif
        endfor
    else " 16 color terminal
        " Check for values from 16 color terminal
        let best = []
        let min  = 100000
        let list = (&t_Co == 16 ? s:basic16 : s:basic16[:7])
        for value in list
            let t = abs(value[0] - a:rgblist[0]) +
                    \ abs(value[1] - a:rgblist[1]) +
                    \ abs(value[2] - a:rgblist[2])
            if min > t
                let min = t
                let best = value
            endif
        endfor
        return best
    endif
  return a:rgblist
endfunction

function! s:PreviewColorName(color) "{{{1
    if s:skip_comments &&
        \ synIDattr(synIDtrans(synID(line('.'), col('.'),1)), 'name') == "Comment"
        " skip coloring comments
        return a:color
    endif
    let name=tolower(a:color)
    let clr = s:colors[name]
    call s:SetMatcher(clr[1:], '\<'.name.'\>\c')
    return a:color
endfu

function! s:PreviewColorHex(match) "{{{1
    if s:skip_comments &&
        \ synIDattr(synIDtrans(synID(line('.'), col('.'),1)), 'name') == 'Comment'
        " skip coloring comments
        return a:match
    endif
    let color = (a:match[0] == '#' ? a:match[1:] : a:match)
    let pattern = color
    if len(color) == 3
        let color = substitute(color, '.', '&&', 'g')
    endif
    if &t_Co == 8 && !has("gui_running")
        " The first 12 color names, can be displayed by 8 color terminals
        let list = values(s:xterm_8colors)
        let idx = match(list, a:match)
        if idx == -1
            " Color can't be displayed by 8 color terminal
            return a:match
        else
            let color = list[idx]
        endif
    endif
    call s:SetMatcher(color, '#'.pattern.'\%(\>\|[-_]\)\@=\c')
    return a:match
endfunction

function! s:GetColorPattern(list) "{{{1
    let list = map(copy(a:list), ' ''\%(\<'' . v:val . ''\>\)'' ')
    return join(list, '\|')
endfunction

function! s:GetMatchList() "{{{1
    " this is buffer-local!
    return filter(getmatches(), 'v:val.group =~ ''^Color_\x\{6}$''')
endfunction

function! s:Init(...) "{{{1
    let s:force_hl = !empty(a:1)

    " pattern/function dict
    " Needed for s:ColorMatchingLines(), disabled, as this is too slow.
    "let s:pat_func = {'#\x\{3,6\}': function('<sid>PreviewColorHex'),
    "            \ 'rgba\=(\s*\%(\d\+%\?\D*\)\{3,4})':
    "            \ function('<sid>ColorRGBValues'),
    "            \ 'hsla\=(\s*\%(\d\+%\?\D*\)\{3,4})':
    "            \ function('s:ColorHSLValues')}

    " Cache old values
    if !exists("s:old_tCo")
        let s:old_tCo = &t_Co
    endif

    if !exists("s:swap_fg_bg")
        let s:swap_fg_bg = 0
    endif

    " Enable Autocommands
    if exists("g:colorizer_auto_color")
        call Colorizer#AutoCmds(g:colorizer_auto_color)
    endif

    if exists("g:colorizer_debug")
        let s:debug = 1
    endif

    if exists("g:colorizer_skip_comments")
        let s:skip_comments = g:colorizer_skip_comments
    else
        let s:skip_comments = 0
    endif

    " foreground / background contrast
    let s:predefined_fgcolors = {}
    let s:predefined_fgcolors['dark']  = ['444444', '222222', '000000']
    let s:predefined_fgcolors['light'] = ['bbbbbb', 'dddddd', 'ffffff']
    if !exists('g:colorizer_fgcontrast')
        " Default to black / white
        let g:colorizer_fgcontrast = len(s:predefined_fgcolors['dark']) - 1
    elseif g:colorizer_fgcontrast >= len(s:predefined_fgcolors['dark'])
        call s:Warn("g:colorizer_fgcontrast value invalid, using default")
        let g:colorizer_fgcontrast = len(s:predefined_fgcolors['dark']) - 1
    endif

    if !exists("s:old_fgcontrast")
        " if the value was changed since last time, 
        " be sure to clear the old highlighting.
        let s:old_fgcontrast = g:colorizer_fgcontrast
    endif

    if exists("g:colorizer_swap_fgbg")
        if s:swap_fg_bg != g:colorizer_swap_fgbg
            let s:force_hl = 1
        endif
        let s:swap_fg_bg = g:colorizer_swap_fgbg
    endif

    if exists("g:colorizer_colornames")
        if exists("s:color_names") &&
        \ s:color_names != g:colorizer_colornames
            let s:force_hl = 1
        endif
        let s:color_names = g:colorizer_colornames
    else
        let s:color_names = 1
    endif

    if exists("g:colorizer_syntax") && g:colorizer_syntax
        let s:color_syntax = 1
    else
        let s:color_syntax = 0
    endif

    if !s:force_hl && s:old_fgcontrast != g:colorizer_fgcontrast
                \ && s:swap_fg_bg == 0
        " Doesn't work with swapping fg bg colors
        let s:force_hl = 1
        let s:old_fgcontrast = g:colorizer_fgcontrast
    endif

    " User manually changed the &t_Co option, so reset it
    if s:old_tCo != &t_Co
        unlet! s:colortable
    endif

    if !exists("s:init_css") || !exists("s:colortable") ||
        \ empty(s:colortable)
	" Only calculate the colortable when running
        if &t_Co == 8
	    let s:colortable = map(range(0,7), 's:Xterm2rgb16(v:val)')
        elseif &t_Co == 16
	    let s:colortable = map(range(0,15), 's:Xterm2rgb16(v:val)')
        elseif &t_Co == 88
	    let s:colortable = map(range(0,87), 's:Xterm2rgb88(v:val)')
	" terminal with 256 colors or gVim
        elseif &t_Co == 256 || empty(&t_Co)
	    let s:colortable = map(range(0,255), 's:Xterm2rgb256(v:val)')
	endif
        if s:debug && exists("s:colortable")
            let g:colortable = s:colortable
        endif
        let s:init_css = 1
    elseif s:force_hl
        call Colorizer#ColorOff()
    endif
    if has("gui_running") || &t_Co >= 8 || s:HasColorPattern()
	" The list of available match() patterns
	let s:match_list = s:GetMatchList()
	" If the syntax highlighting got reset, force recreating it
	if ((empty(s:match_list) || !hlexists(s:match_list[0].group) ||  
	    \ empty(synIDattr(hlID(s:match_list[0].group), 'fg'))) &&
            \ !s:force_hl)
	    let s:force_hl = 1
	endif
        if &t_Co > 16 || has("gui_running")
            let s:colors = (exists("g:colorizer_x11_names") ?
                \ s:x11_color_names : s:w3c_color_names)
        elseif &t_Co == 16
            " should work with 16 colors terminals
            let s:colors = s:xterm_16colors
        else
            let s:colors = s:xterm_8colors
        endif
        call map(s:match_list, 'v:val.pattern')
    else
        throw "nocolor"
    endif
endfu

function! s:SaveRestoreOptions(save, dict, list) "{{{1
    if a:save
        return s:SaveOptions(a:list)
    else
	for [key, value] in items(a:dict)
            if key !~ '@'
                call setbufvar('', '&'. key, value)
            else
                call call('setreg', [key[1]] + value)
            endif
            unlet value
	endfor
    endif
endfun

function! s:SaveOptions(list) "{{{1
    let save = {}
    for item in a:list
        if item !~ '^@'
            exe "let save.". item. " = &l:". item
        else
            let save[item] = []
            call add(save[item], getreg(item[1]))
            call add(save[item], getregtype(item))
        endif
	if item == 'ma' && !&l:ma
	    setl ma
	elseif item == 'ro' && &l:ro
	    setl noro
	elseif item == 'lz' && &l:lz
	    setl lz
        elseif item == 'ed' && &g:ed
            setl noed
        elseif item == 'gd' && &g:gd
            setl nogd
	endif
    endfor
    return save
endfunction

function! s:StripParentheses(val) "{{{1
    return split(matchstr(a:val, '^\(hsl\|rgb\)a\?\s*(\zs[^)]*\ze)'), '\s*,\s*')
endfunction

function! s:ColorRGBValues(val) "{{{1
    if s:skip_comments &&
        \ synIDattr(synIDtrans(synID(line('.'), col('.'),1)), 'name') == "Comment"
        " skip coloring comments
        return a:val
    endif
    " strip parantheses and split on comma
    let rgb = s:StripParentheses(a:val)
    if empty(rgb)
        call s:Warn("Error in expression". a:val. "! Please report as bug.")
        return a:val
    elseif len(rgb) == 4
        " drop alpha channel
        call remove(rgb, 3)
    endif
    for i in range(3)
        if rgb[i][-1:-1] == '%'
            let val = matchstr(rgb[i], '\d\+')
            if (val + 0 > 100)
                let rgb[1] = 100
            endif
            let rgb[i] = float2nr((val + 0.0)*255/100)
        else
            if rgb[i] + 0 > 255
                let rgb[i] = 255
            endif
        endif
    endfor
    let clr = printf("%02X%02X%02X", rgb[0],rgb[1],rgb[2])
    call s:SetMatcher(clr, a:val)
    return a:val
endfunction

function! s:ColorHSLValues(val) "{{{1
    if s:skip_comments &&
        \ synIDattr(synIDtrans(synID(line('.'), col('.'),1)), 'name') == "Comment"
        " skip coloring comments
        return a:val
    endif
    " strip parantheses and split on comma
    let hsl = s:StripParentheses(a:val)
    if empty(hsl)
        call s:Warn("Error in expression". a:val. "! Please report as bug.")
        return a:val
    endif
    let str = s:PrepareHSLArgs(hsl)

    call s:SetMatcher(str, a:val)
    return a:val
endfu

function! s:HSL2RGB(h, s, l) "{{{1
    let s = a:s + 0.0
    let l = a:l + 0.0
    if  l <= 0.5
        let m2 = l * (s + 1)
    else
        let m2 = l + s - l * s
    endif
    let m1 = l * 2 - m2
    let r = float2nr(s:Hue2RGB(m1, m2, a:h + 120))
    let g = float2nr(s:Hue2RGB(m1, m2, a:h))
    let b = float2nr(s:Hue2RGB(m1, m2, a:h - 120))
    return printf("%02X%02X%02X", r, g, b)
endfunction

function! s:Hue2RGB(m1, m2, h) "{{{1
    let h = (a:h + 0.0)/360
    if h < 0
        let h = h + 1
    elseif h > 1
        let h = h - 1
    endif
    if h * 6 < 1
        let res = a:m1 + (a:m2 - a:m1) * h * 6
    elseif h * 2 < 1
        let res = a:m2
    elseif h * 3 < 2
        let res = a:m1 + (a:m2 - a:m1) * (2.0/3.0 - h) * 6
    else
       let res = a:m1
    endif
    return round(res * 255)
endfunction

function! s:Modifylists(la, lb, op) "{{{1
    if a:op == '+'
        return [ a:la[0] + a:lb[0], 
            \    a:la[1] + a:lb[1],
            \    a:la[2] + a:lb[2]]
    else
        return [ a:la[0] - a:lb[0], 
            \    a:la[1] - a:lb[1],
            \    a:la[2] - a:lb[2]]
    endif
endfu

function! s:Rgb2xterm(color) "{{{1
" selects the nearest xterm color for a rgb value like #FF0000
" hard code values for 000000 and FFFFFF, they will be called many times
" so make this fast
    if len(a:color) <= 3
        " a:color is already a terminal color
        return a:color
    endif
    if !exists("s:colortable")
        call s:Init('')
    endif
    let color = (a:color[0] == '#' ? a:color[1:] : a:color)
    if ( color == '000000')
	return 0
    elseif (color == 'FFFFFF')
	return 15
    else
	let r = '0x'.color[0:1]+0
	let g = '0x'.color[2:3]+0
	let b = '0x'.color[4:5]+0

        " Try exact match first
        let i = index(s:colortable, [r, g, b])
        if i > -1
            return i
        endif

        " Grey scale ?
        if ( r == g &&  r == b )
            if &t_Co == 256
                " 0 and 15 have already been take care of
                if r < 5
                    return 0 " black
    "            elseif r == 127
    "                return 8 " from 16 color xterm
    "            elseif r == 229
    "                return 7 " from 16 color xterm
                elseif r > 244
                    return 15 " white
                endif
                " grey cube starts at index 232
                return 232+(r-5)/10
            elseif &t_Co == 88
                if r < 23
                    return 0 " black
                elseif r < 69
                    return 80
                elseif r > 250
                    return 15 " white
                else
                    " should be good enough
                    return 80 + (r-69)/23
                endif
            endif
        endif

        " Round to the next step in the xterm color cube
        " euclidian distance would be needed,
        " but this works good enough and is faster.
        let round = s:RoundColor(r, g, b)
        " Return closest match or -1 if not found
        return index(s:colortable, round)
    endif
endfunction

function! s:Warn(msg) "{{{1
    let msg = 'Colorizer: '. a:msg
    echohl WarningMsg
    echomsg msg
    echohl None
    let v:errmsg = msg
endfu

function! s:HasColorPattern() "{{{1
    let _pos    = winsaveview()
    let pattern = [ '#\x\{3,6}\>', 'rgba\=(\s*\%(\d\+%\?\D*\)\{3,4})',
                \ 'hsla\=(\s*\%(\d\+%\?\D*\)\{3,4})',
                \ s:GetColorPattern(keys(s:colors))]
    call cursor(1,1)
    for pat in pattern
        let found = search(pat, 'cnW')
        if found
            break
        endif
    endfor

    call winrestview(_pos)
    return found
endfunction

function! s:PrepareHSLArgs(list) "{{{1
    let hsl=a:list
    if len(hsl) == 4
        " drop alpha channel
        call remove(hsl, 3)
    endif
    let hsl[0] = (matchstr(hsl[0], '\d\+') + 360)%360
    let hsl[1] = (matchstr(hsl[1], '\d\+') + 0.0)/100
    let hsl[2] = (matchstr(hsl[2], '\d\+') + 0.0)/100
    return s:HSL2RGB(hsl[0], hsl[1], hsl[2])
endfu
function! s:SyntaxMatcher(enable) "{{{1
    let did_clean = {}
    for hi in s:GetMatchList()
        if !get(did_clean, hi.group, 0)
            let did_clean[hi.group] = 1
            exe "sil! syn clear" hi.group
        endif
        if a:enable
            exe "syn match" hi.group "excludenl /". hi.pattern. "/ display containedin=ALL"
            " We have syntax highlighting, can clear the matching
            " ignore errors (just in case)
            sil! call matchdelete(hi.id)
        endif
    endfor
"    if a:enable
"        unlet s:match_list
"    endif
endfu

function! Colorizer#ColorToggle() "{{{1
    if !exists("s:match_list") || empty(s:match_list)
        call Colorizer#DoColor(0, 1, line('$'))
    else
        call Colorizer#ColorOff()
    endif
endfu

function! Colorizer#ColorOff() "{{{1
    for _match in s:GetMatchList()
        sil! call matchdelete(_match.id)
    endfor
    unlet! s:match_list
endfu

function! Colorizer#DoColor(force, line1, line2, ...) "{{{1
    " initialize plugin
    try
        call s:Init(a:force)
        if exists("a:1")
            let s:color_syntax = ( a:1 =~# '^\%(syntax\|nomatch\)$' )
        endif
    catch /nocolor/
        " nothing to do
        call s:Warn("Your terminal doesn't support colors or no colors". 
                    \ 'found in the current buffer!')
        return
    endtry

    " too slow
    "for name in keys(s:colors)
    "    call s:PreviewColorName(name)
    "endfor
    
    " too slow:
    "for line in range(1,line('$'))
    "    call s:ColorMatchingLines(line)
    "endfor
    let _a   = winsaveview()
    let save = s:SaveRestoreOptions(1, {},
            \ ['mod', 'ro', 'ma', 'lz', 'ed', 'gd', '@/'])

    let n_flag = v:version > 703 || ( v:version == 703 && has("patch627"))
    " highlight Hex Codes:
    "
    " The :%s command is a lot faster than this:
    ":g/#\x\{3,6}\>/call s:ColorMatchingLines(line('.'))
    " Should color #FF0000
    "              #F0F
    "              #FFF
    "
    " Hexcodes should be word-bounded, but could also be delimited by [-_], so
    " allow those to delimit the end of the pattern
    let cmd = printf(':sil %d,%ds/#\%(\x\{3}\|\x\{6}\)\%(\>\|[-_]\)\@=/'.
        \ '\=s:PreviewColorHex(submatch(0))/egi%s', a:line1, a:line2,
        \ n_flag ? 'n' : '')
    exe cmd
    if &t_Co > 16 || has("gui_running")
    " Also support something like
    " CSS rgb(255,0,0)
    "     rgba(255,0,0,1)
    "     rgb(10%,0,100%)
    "     hsl(0,100%,50%) -> hsl2rgb conversion RED
    "     hsla(120,100%,50%,1) Lime
    "     hsl(120,100%,25%) Darkgreen
    "     hsl(120, 100%, 75%) lightgreen
    "     hsl(120, 75%, 75%) pastelgreen
    " highlight rgb(X,X,X) values
        let pat = '\s*(\s*\%%(\d\+%%\?[^0-9)]*\)\{3,4})'
        let cmd = printf(':sil %d,%ds/rgba\='. pat. '/'. 
            \ '\=s:ColorRGBValues(submatch(0))/egi%s', a:line1, a:line2,
            \ n_flag ? 'n' : '')
        exe cmd
        " highlight hsl(X,X,X) values
        let cmd = printf(':sil %d,%ds/hsla\='. pat. '/'.
            \'\=s:ColorHSLValues(submatch(0))/egi%s', a:line1, a:line2,
            \ n_flag ? 'n' : '')
        exe cmd
    endif
    " highlight Colornames
    if exists("s:color_names") && s:color_names
        let s_cmd =
            \ printf(':sil %d,%ds/%s/\=s:PreviewColorName(submatch(0))/egi%s',
            \ a:line1, a:line2, s:GetColorPattern(keys(s:colors)),
            \ n_flag ? 'n' : '')
        exe s_cmd
        " Somehow, when performing above search, the pattern remains in the
        " search history and this can be disturbing, so delete it from there.
        call histdel('/', -1)
    endif
    " convert matches into synatx highlighting, so TOhtml can display it
    " correctly
    call s:SyntaxMatcher(s:color_syntax)
    call s:SaveRestoreOptions(0, save, [])
    call winrestview(_a)
endfu

function! Colorizer#RGB2Term(arg) "{{{1
    if a:arg =~ '^rgb'
        let clr    = s:StripParentheses(a:arg)
        let color  = printf("#%02X%02X%02X", clr[0], clr[1], clr[2])
    else
        let color  = a:arg[0] == '#' ? a:arg : #.a:arg
    endif

    let tcolor = s:Rgb2xterm(color)
    call s:DoHlGroup(color[1:])
    exe "echohl" color[1:]
    echo a:arg. " => ". tcolor
    echohl None
endfu

function! Colorizer#HSL2Term(arg) "{{{1
    let hsl = s:StripParentheses(a:arg)
    if empty(hsl)
        call s:Warn("Error evaluating expression". a:val. "! Please report as bug.")
        return a:val
    endif
    let str = s:PrepareHSLArgs(hsl)

    let tcolor = s:Rgb2xterm('#'.str)
    call s:DoHlGroup(str)
    exe "echohl" str
    echo a:arg. " => ". tcolor
    echohl None
endfu

function! Colorizer#AutoCmds(enable) "{{{1
    if a:enable
        aug Colorizer
            au!
            au CursorHold,CursorHoldI,InsertLeave * silent call
                        \ Colorizer#DoColor('', line('.'), line('.'))
            au GUIEnter,BufWinEnter * silent call
                        \ Colorizer#DoColor('', 1, line('$'))
            au ColorScheme * silent call Colorizer#DoColor('!', 1, line('$'))
        aug END
    else
        aug Colorizer
            au!
        aug END
        aug! Colorizer
    endif
endfu

function! Colorizer#LocalFTAutoCmds(enable) "{{{1
    if a:enable
        aug FTColorizer
            au!
            au CursorHold,CursorHoldI,InsertLeave <buffer> silent call
                        \ Colorizer#DoColor('', line('.'), line('.'))
            au GUIEnter,ColorScheme <buffer> silent
                        \ call Colorizer#DoColor('!', 1, line('$'))
        aug END
        if !exists("b:undo_ftplugin")
            " simply unlet a dummy variable
            let b:undo_ftplugin = 'unlet! b:Colorizer_foobar'
        endif
        " Delete specific auto commands, because the filetype
        " has been changed.
        let b:undo_ftplugin .= '| exe "sil! au! FTColorizer"'  
        let b:undo_ftplugin .= '| exe "sil! aug! FTColorizer"'  
        let b:undo_ftplugin .= '| exe ":ColorClear"'
    else
        aug FTColorizer
            au!
        aug END
        aug! FTColorizer
    endif
endfu

function! Colorizer#SwitchContrast() "{{{1
    if exists("s:swap_fg_bg") && s:swap_fg_bg
        call s:Warn('Contrast Adjustment does not work with swapped foreground colors!')
        return
    endif
    " make sure, g:colorizer_fgcontrast is set up
    if !exists('g:colorizer_fgcontrast')
        " Default to black / white
        let g:colorizer_fgcontrast = len(s:predefined_fgcolors['dark']) - 1
    endif
    let g:colorizer_fgcontrast-=1
    if g:colorizer_fgcontrast < -1
        let g:colorizer_fgcontrast = len(s:predefined_fgcolors['dark']) - 1
    endif
    call Colorizer#DoColor(1, 1, line('$'))
endfu

function! Colorizer#SwitchFGBG() "{{{1
    if !exists("s:round")
        let s:round = 1
    else
        let s:round += 1
    endif
    let range = [ 1, -1, 0]
    let s:swap_fg_bg = range[s:round % 3]
    call Colorizer#DoColor(1, 1, line('$'))
endfu

" DEBUG TEST "{{{1
if !s:debug
    let &cpo = s:cpo_save
    unlet s:cpo_save
    finish
endif

function! s:ColorMatchingLines() "{{{2
    " Programmatic approach to highlight all hex values as colors.
    " Surprisingly a lot slower than calling 
    " :s/#\x\{3,6}/\=s:ColorMatchingLines1(submatch(0))/g
    let pat = s:GetColorPattern(keys(s:pat_func)). '\|'.
            \ s:GetColorPattern(keys(s:colors))
    let pat = substitute(pat, '\\<#', '#', 'g')
    for content in range(1, line('$'))
        let line = getline(content)
        let cnt  = 0
        while 1
            let color = matchstr(line, pat, 0, cnt)
            if empty(color)
                break
            else
                let key  = color
                if color =~ keys(s:pat_func)[0]
                    let key = keys(s:pat_func)[0]
                endif
                let Func = get(s:pat_func, key,
                            \ function('s:PreviewColorName'))
                call call(Func, [color])
                let cnt  += 1
            endif
        endw
    endfor
endfu
" Autoloadable functions

fu! Test1() "{{{2
    return map(range(0,254), 's:Xterm2rgb256(v:val)')
endfu
"
fu! Test2() "{{{2
    let list=[]
    for c in range(0, 254)
        let css_color = s:Xterm2rgb256(c)
        call add(list, css_color)
    endfor
   return list
endfu



" Plugin folklore and Vim Modeline " {{{1
let &cpo = s:cpo_save
unlet s:cpo_save
" vim: set foldmethod=marker et fdl=0:
