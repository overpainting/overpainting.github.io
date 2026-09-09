#import "../theme.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: rect, chevron, pill, brace
#set page(width: colwidth, height: auto, margin: linestroke, fill: none)

#let tw = 0
#let img = (1, 2, 3)
#let w = imwidth(5)
#let inset = 2pt

#let layerargs = (inset: inset, stroke: black + linestroke, shape: pill, fill: white)
#let layerwidth(n) = n*w + (gutter + inset) * (n - 1)
#let layer(pos, label) = node(pos, text(label, size: 7pt), width: w, ..layerargs)
#let blockn = 5
#let fadebox = place(horizon + right, dx: -4mm, box(width: -6mm, height: 4mm, fill: gradient.linear(white, white, rgb(255, 255, 255, 0))))
#let teamworkgrad = gradient.linear(oklch(79%, 0.1, 32deg), oklch(79%, 0.1, 306deg), oklch(79%, 0.1, 195deg))
#let teamworkgradplus = gradient.linear(oklch(79%, 0.1, 32deg), oklch(79%, 0.1, 306deg), oklch(79%, 0.1, 195deg), white)

#let dblock(y, single: false, start: -1) = (
  for i in (1, 2, 3, 4) {
    for (j, k) in (start, 0, 1, 2, 3, 4, 5).windows(2) {
      edge((i, y + j), (i, y + k))
    }
    // node((i, 5), width: 1mm, height: 1mm, fill: black, shape: circle)
  },
  for (i, n) in ((0, [Mod]), (1, [QKV]), (3, [FF#sub[1]]), (4, [FF#sub[2]])) {
    node((1, y+i), width: w - 2*inset)
    if single {
      node((4, y+i), width: w - 2*inset)
      node(enclose: ((1, y+i), (4, y+i)), n, ..layerargs, fill: teamworkgradplus)
    } else {
      node((3, y+i), width: w - 2*inset)
      node(enclose: ((1, y+i), (3, y+i)), n, ..layerargs, fill: teamworkgrad)
      layer((4, y+i), n)
    }
  },
  node((1, y+2), width: w - 2*inset),
  node((4, y+2), width: w - 2*inset),
  node(enclose: ((1, y+2), (4, y+2)), [Attention], ..layerargs),
)

#set text(size: 8pt)
#align(center, diagram(
  cell-size: (w, 0pt),
  //debug: true,
  spacing: (gutter, gutter/2),
  node((1, 0), image("./fur_apple.input.webp", width: w), inset: 0pt, stroke: black + 2*linestroke, shape: rect),
  node((2, 0), image("./fur_apple.mask.webp", width: w), inset: 0pt, stroke: black + 2*linestroke, shape: rect),
  node((3, 0), image("./fur_apple.noisy.webp", width: w), inset: 0pt, stroke: black + 2*linestroke, shape: rect),
  node((4, 0), text(size: 10pt)["fur"], inset: 2mm, shape: rect),
  ..dblock(1),
  for i in range(1, 5) {
    node((i, 1 + blockn), sym.dots.v, inset: 1pt)
  },
  ..dblock(3 + blockn, single: true, start: -2),
  for i in range(1, 4) {
    node((i, 3 + blockn * 2), sym.dots.v, inset: 1pt)
  },
  edge((3, 3 + blockn * 2), (3, 4 + blockn * 2)),
  node((3, 4 + blockn * 2), image("./fur_apple.ours.webp", width: w), inset: 0pt, stroke: black + 2*linestroke, shape: rect),
  node(enclose: ((1, 1), (1, 0 + blockn)), shape: brace.with(dir: left)),
  edge((0.5, 1), (0.5, 0 + blockn), [Double Block #(sym.times)19], stroke: none, label-angle: 90deg, label-sep: 2.5mm),
  node(enclose: ((1, 3 + blockn), (1, 2 + 2*blockn)), shape: brace.with(dir: left)),
  edge((0.5, 3 + blockn), (0.5, 2 + 2*blockn), [Single Block #(sym.times)38], stroke: none, label-angle: 90deg, label-sep: 2mm),
))
#set text(size: 9pt)
#align(center, diagram(
  spacing: 0mm,
  node((0, 0), [~~~~~~~~], ..layerargs),
  node((1, 0), [Base Layer]),
  node((2, 0), width: 6mm),
  node((3, 0), [~~~~~~~~], ..layerargs, fill: teamworkgrad),
  node((4, 0), [Teamwork-Adapted Layer]),
))
