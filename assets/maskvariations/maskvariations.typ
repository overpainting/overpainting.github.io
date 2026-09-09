#import "../theme.typ": *
#set page(width: colwidth, height: auto, margin: (bottom: linestroke, top: 1pt, rest: 0mm), fill: none)
#set text(..textstyle)
#import "@preview/cetz:0.3.4": canvas, draw

#let variations = ("precise", "interrupted", "verygrey", "white")
#let shift = 4mm
#let scale = 0.66
#let w = (colwidth - gutter * variations.len() - linestroke)/(variations.len() + 1)

#align(center, canvas({
    draw.rect((0, 0), (rel: (w, w)), name: "img", stroke: black + 2*linestroke)
    draw.content("img", image("./input.webp", width: w))
    draw.content("img.north", [Input], anchor: "south", padding: (bottom: gutter))

    for (i, var) in variations.enumerate() {
      draw.rect(((w + gutter) * (i + 1), 0), (rel: (w, w)), name: str(i), stroke: black + 2*linestroke)
      draw.content(str(i), image(var + ".output.webp", width: w))
    }

    for (i, var) in variations.enumerate() {
      draw.rect(((w + gutter) * (i + 1) + (w - scale * w) / 2, w + gutter), (rel: (scale * w, scale * w)), name: str(i), stroke: black + 2*linestroke)
      draw.content(str(i), image(var + ".mask.webp", width: scale * w))
    }
}))
