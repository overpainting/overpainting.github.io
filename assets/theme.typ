// constants from the official CVPR template (cvpr.sty)

#import "@preview/fletcher:0.5.8": node

#let textwidth = 6.875in
#let colwidth = (textwidth - 0.3125in) / 2
#let textheight = 8.875in

#let linestroke = 10pt * 0.08

#let linestyle = (stroke: linestroke + black)
// The image is drawn over the inner half of the stroke; a `fill` goes in the
// body with it so transparent images keep the same visual frame width.
#let imframe(..args, color: black, fill: none) = rect(
  if fill == none { image(..args) } else { block(fill: fill, image(..args)) },
  stroke: 2*linestroke + color, inset: 0mm)
// cvpr.sty loads the times package; TeX Gyre Termes shares its Nimbus Roman design
#let textstyle = (size: 8pt, font: "TeX Gyre Termes")

#let gutter = 2mm
// Gap between a text label and the images below it.
#let labelgap = 1mm

// Frame strokes are centered on the image edge, so they overhang the layout
// box by `linestroke`. The content area is inset by that overhang, so frames
// laid out to fill it put their outer stroke edge exactly at `width`, flush
// with the text column. `hairline` pads every side so renderers never clip
// the outermost ink.
// Vertically, glyphs rise above the cap-height and drop below the baseline
// that bound text, so `bleed` keeps them on the page; `bottom` adds room for
// insets placed past the last row.
// Website: transparent, so figures sit on the page background.
#let hairline = 0.5pt
#let bleed = 2pt
#let figpage(width, bottom: 0pt) = (
  width: width + 2*hairline,
  height: auto,
  margin: (x: hairline + linestroke, top: bleed, bottom: bleed + bottom),
  fill: none,
)

// Width of each of n framed images that, with n-1 gutters, fill the content area.
#let imwidth(n, gutter: gutter, col: true) = ((if col { colwidth } else { textwidth }) - 2*linestroke - gutter*(n - 1))/n
