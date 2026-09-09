#import "../theme.typ": *
#set page(width: textwidth, height: auto, margin: linestroke, fill: none)
#set text(..textstyle)
#set text(size: 7pt)

#import "@preview/cetz:0.3.2": canvas, draw
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: rect, chevron, pill

#let iw = textwidth*0.08
#let imnode(pos, img, width, name) = node(pos, image(img, width: width), shape: rect, inset: 0pt, stroke: 2*linestroke, name: name)

#let blockargs = (corner-radius: 2mm, fill: white, stroke: linestroke + black)
#let sectionargs = (corner-radius: 2mm, fill: luma(90%), layer: -2)

#let qx = 2
#let qy = 0.5
#let fx = 4
#let fy = 1
#let lx = 7
#let ly = 0.1
#let mx = 7
#let my = 1.9
#let tx = 9
#let ty = my
#let bx = 10

#let thickness = 0.5pt
#let sc = oklch(50%, 0.25, 280deg) + thickness
#let ec = oklch(50%, 0.25, 31deg) + thickness
#let pc = oklch(50%, 0.25, 145deg) + thickness
#let mc = oklch(50%, 0.25, 315deg) + thickness
#let lc = oklch(70%, 0.5, 100deg) + thickness

#let chatw = 25mm
#let promptreroute = (4, 0)

#align(center, diagram(
  //debug: true,
  spacing: (3mm, 0mm),
  cell-size: (0mm, 4mm),

  // Source
  imnode((0, 0), "./source.webp", iw, <source>),
  node((rel: (0mm, 2mm), to: <source.north>), text(size: 8pt, weight: "bold")[Source], inset: 0pt),

  // Qwen
  //node((qx, qy), height: 0mm, conversation, ..blockargs),
  node((qx, qy), [Qwen], name: <qwen>, inset: 0mm),
  node((qx + 0.2, 1), text(size: 6pt)[Suggest edits], shape: pill, fill: white, stroke: blue, width: chatw, name: <long>),
  node((qx - 0.2, 1.5), text(size: 6pt)[replace mirror with a wall covered in plants], shape: pill, fill: white, stroke: green, width: chatw, name: <long>),
  node((qx + 0.2, 2), text(size: 6pt)[Abbreviate], shape: pill, fill: white, stroke: blue, width: chatw, name: <reply>),
  node((qx - 0.2, 2.75), text(size: 6pt)[covered in plants], shape: pill, fill: white, stroke: green, width: chatw, name: <short>),
  node(enclose: (<qwen>, <long>, <short>), ..blockargs, name: <chat>),

  node(enclose: (<chat>, (qx, -1)), ..sectionargs, snap: -1, align(top)[#text(size: 8pt, weight: "bold")[Prompt Generation]]),

  // FLUX Kontext
  node(enclose: ((fx, fy + 0.5), (fx, fy - 0.5)), rotate(90deg, reflow: true)[FLUX Kontext], ..blockargs, name: <flux>),
  edge((fx, 1), (bx, 1), "-|>", stroke: ec),
  // edge(<long.east>, (<long.east>, "-|", <flux.south>), <flux.south>, "-|>", stroke: pc),
  edge(<long.east>, (<long.east>, "-|", <flux.south>), "-|>", stroke: pc),

  node(enclose: (<flux>, (fx, -1)), ..sectionargs, snap: -1, align(top)[#text(size: 8pt, weight: "bold")[Edit Generation]]),

  // LightGlue
  node((lx, ly), rotate(90deg, reflow: true)[LightGlue], ..blockargs, name: <lightglue>),
  edge(<source.east>, ((), "-|", (mx - 1, 1)), (to: (lx - 1, ly), rel: (0mm, 4mm)), (to: (lx, ly), rel: (0mm, 4mm)), "-|>", stroke: sc),
  edge((fx, 1), (fx + 1, 1), (to: (fx + 1, ly), rel: (0mm, -4mm)), (to: (lx, ly), rel: (0mm, -4mm)), "-|>", stroke: ec),

  imnode(((lx+tx)/2, ly + 0.3), "./featurematches.png", iw, <features>),
  node((lx+2, ly), text(size: 15pt, fill: green)[✔], shape: circle, fill: white, stroke: green, inset: 0mm, name: <filter>),
  edge(<lightglue>, <filter>, "-|>", stroke: lc),

  node(enclose: (<lightglue>, <features>, <filter>), ..sectionargs, snap: -1, align(top)[#text(size: 8pt, weight: "bold")[Filtering]]),

  // BiRefNet
  node((mx, my), rotate(90deg, reflow: true)[BiRefNet #linebreak() (Finetuned)], ..blockargs, name: <birefnet>),
  imnode(((mx+tx)/2, my - 0.35), "./mask.webp", 0.6*iw, <mask>),
  edge(<source.east>, ((), "-|", (mx - 1, 1)), (to: (mx - 1, my), rel: (0mm, 4mm)), (to: (mx, my), rel: (0mm, 4mm)), "-|>", stroke: sc, crossing: true),
  edge((fx, 1), (fx + 1, 1), (to: (fx + 1, my), rel: (0mm, -4mm)), (to: (mx, my), rel: (0mm, -4mm)), "-|>", stroke: ec),

  // Other source edges (have to be here because of crossing)
  edge(<source.east>, ((), "-|", <flux.north>), <flux.north>, "-|>", stroke: sc),
  edge(<source>, "r,r", <chat>, "-|>", stroke: sc),

  // Trimap
  node((tx, ty), rotate(90deg, reflow: true)[Randomize], ..blockargs, name: <trimap>),
  edge("l,l", "<|-", stroke: mc),
  edge("r", "-|>", stroke: mc),

  node(enclose: (<birefnet>, <mask>, <trimap>), ..sectionargs, snap: -1, align(bottom)[#text(size: 8pt, weight: "bold")[Mask Generation]]),

  // Batch
  node((bx, -1), text(size: 8pt, weight: "bold")[Training], inset: 0pt),
  imnode((bx, 0), "./source.webp", iw, <original>),
  imnode((bx, 1), "./edited.webp", iw, <edited>),
  imnode((bx, 2), "./trimap.webp", iw, <mask>),
  node((bx, 3.2), text(size: 7pt)["covered in plants"], inset: 2pt, name: <prompt>),

  edge(<short.east>, (<short.east>, "-|", promptreroute), (promptreroute, "|-", <prompt.west>), <prompt.west>, "-|>", stroke: pc),
  //edge(<short.east>, (<short.east>, "-|", <prompt.west>), "-|>", stroke: pc),
  edge(<source.east>, (6, 0), (6, -1), (bx - 0.6, -1), (bx - 0.6, 0), <original.west>, "-|>", stroke: sc),
))

