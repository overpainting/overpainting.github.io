// constants from the official SIGGRAPH template

#import "@preview/fletcher:0.5.8": node

#let textwidth = 8.5in - 52pt*2
#let colwidth = (textwidth - 24pt) / 2
#let textheight = 11in - 52pt - 75pt

#let linestroke = 10pt * 0.08

#let linestyle = (stroke: linestroke + black)
#let imframe(..args, color: black) = rect(image(..args), stroke: 2*linestroke + color, inset: 0mm)
#let textstyle = (size: 8pt, font: "Libertinus Serif")

#let gutter = 2mm
#let imwidth(n, gutter: gutter, col: true) = (if col { colwidth } else { textwidth } - gutter*(n - 1) - linestroke*(n - 2))/n
