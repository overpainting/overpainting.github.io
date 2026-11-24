#import "../theme.typ": *
#set page(..figpage(colwidth))
#set text(..textstyle)
#import "@preview/cetz:0.3.4": canvas, draw

#let variations = ("apple_side_precise", "apple_side_bw", "apple_side_bg", "apple_side_crispedge")
#let shift = 4mm
#let scale = 0.66
#let w = imwidth(variations.len() + 1)

#align(center, canvas({
    draw.rect((0, 0), (rel: (w, w)), name: "img", stroke: black + 2*linestroke)
    draw.content("img", image("./apple_fur_side.input.webp", width: w))
    draw.content("img.north", [Input], anchor: "south", padding: (bottom: gutter))

    for (i, var) in variations.enumerate() {
      draw.rect(((w + gutter) * (i + 1), 0), (rel: (w, w)), name: str(i), stroke: black + 2*linestroke)
      draw.content(str(i), image(var + ".ours.webp", width: w))
    }

    for (i, var) in variations.enumerate() {
      draw.rect(((w + gutter) * (i + 1) + (w - scale * w) / 2, w + gutter), (rel: (scale * w, scale * w)), name: str(i), stroke: black + 2*linestroke)
      draw.content(str(i), image(var + ".mask.webp", width: scale * w))
    }
}))
