#import "../theme.typ": *
#import "@preview/cetz:0.3.4": canvas, draw, decorations
#set page(..figpage(colwidth))
#set text(..textstyle)

#let w = imwidth(5)
#let pitch = w + gutter
// Center x of stream column i (1: source, 2: trimap, 3: noise, 4: text).
#let col(i) = (i - 1) * pitch + w/2

#let lh = 3.5mm // layer height
#let rp = lh + 1mm // layer row pitch
#let imgap = 1.5mm // gap between input images and the first layer
#let blocktop = -w - imgap
#let blockbottom = blocktop - 4*rp - lh
#let dotsy = blockbottom - 2.5mm
#let outtop = dotsy - 3mm

#let layerstroke = black + linestroke
#let streamstroke = black + linestroke/2
#let arrowhead = (end: ">", fill: black, scale: 0.4)
// Per-stream colors (source, trimap, noise); the Teamwork layer gradient blends them.
#let streamcolors = (oklch(79%, 0.1, 32deg), oklch(79%, 0.1, 306deg), oklch(79%, 0.1, 195deg))
#let teamworkgrad = gradient.linear(..streamcolors)

// Pill-shaped layer spanning x0..x1 with its top edge at y.
#let layer(x0, x1, y, label, fill: white, size: 8pt) = {
  draw.rect((x0, y), (x1, y - lh), radius: lh/2, stroke: layerstroke, fill: fill)
  draw.content(((x0 + x1)/2, y - lh/2), text(size: size, label))
}

#let framedimage(x, ytop, path) = {
  draw.rect((x - w/2, ytop), (rel: (w, -w)), stroke: black + 2*linestroke, name: "img")
  draw.content("img", image(path, width: w))
}

#align(center, canvas({
  let left = col(1) - w/2
  let right = col(4) + w/2

  // Inputs
  framedimage(col(1), 0, "apple_fur_side.input.webp")
  framedimage(col(2), 0, "apple_fur_side.mask.webp")
  framedimage(col(3), 0, "fur_apple.noisy.webp")
  draw.content((col(4), -w/2), text(size: 10pt)["fur"], name: "prompt")

  // Streams, drawn beneath the layers
  for i in (1, 2, 3) {
    draw.line((col(i), -w), (col(i), dotsy + 1.5mm), stroke: streamstroke)
  }
  draw.line("prompt.south", (col(4), dotsy + 1.5mm), stroke: streamstroke)

  // Transformer block
  for (k, label) in ((0, [Mod]), (1, [QKV]), (3, [FF#sub[1]]), (4, [FF#sub[2]])) {
    let y = blocktop - k*rp
    layer(left, col(3) + w/2, y, label, fill: teamworkgrad)
    layer(col(4) - w/2, right, y, label, size: 7pt)
  }
  layer(left, right, blocktop - 2*rp, [Attention])

  decorations.brace((left - 1mm, blockbottom), (left - 1mm, blocktop), amplitude: 1.5mm, stroke: streamstroke)
  draw.content(
    (left - 3.5mm, (blocktop + blockbottom)/2),
    align(center)[Transformer \ Block #(sym.times)#emph[N]],
    angle: 90deg,
    anchor: "south",
  )

  // Output
  for i in (1, 2, 3, 4) {
    draw.content((col(i), dotsy), sym.dots.v)
  }
  draw.line((col(3), dotsy - 1.5mm), (col(3), outtop), stroke: streamstroke, mark: arrowhead)
  framedimage(col(3), outtop, "apple_fur_side.ours.webp")

  // Teamwork LoRA inset. Each stream runs straight down its lane through the
  // frozen W; a LoRA branch off each lane goes through A, is summed across
  // streams, and comes back through B to be added onto the lane.
  {
    let (bw, bh) = (5.2mm, 3mm) // matrix box size, wide enough for the A/B labels
    let sr = 1.6mm // sum node radius
    let pr = 1.1mm // add node radius
    let dw = bw + 0.8mm // lane offset from its A/B boxes
    let du = dw + bw + 1.2mm // spacing between A/B columns
    let bubble = luma(232)

    let x1 = col(3) - w/2 - 3mm // bubble right edge, clear of the output image
    let ax = (x1 - 1mm - bw/2 - dw - 2*du, x1 - 1mm - bw/2 - dw - du, x1 - 1mm - bw/2 - dw)
    // Each stream's lane runs to the right of its A/B boxes.
    let lane(j) = ax.at(j) + dw
    let x0 = ax.at(0) - bw/2 - 1mm // bubble left edge

    let top = dotsy - 2.5mm
    let jy = top - 1.5mm // branch junctions
    let ay = jy - 1.5mm // top of A and W boxes
    let sy = ay - bh - 4.5mm // center of the sum node
    let by = sy - 4.5mm // top of B boxes
    let py = by - bh - 2mm // center of the add nodes
    let bottom = py - pr - 1.5mm

    let sx = ax.at(1)
    let matrix(x, y, fill, body) = {
      draw.rect((x - bw/2, y), (rel: (bw, -bh)), fill: fill, stroke: layerstroke)
      draw.content((x, y - bh/2), text(size: 5pt, body))
    }

    // Speech bubble, with its tail over FF2 reaching the pill's horizon.
    let tx = (x0 + x1)/2
    draw.line((tx - 2mm, top - 1mm), (tx, blockbottom + lh/2), (tx + 2mm, top - 1mm), close: true, fill: bubble, stroke: none)
    draw.rect((x0, top), (x1, bottom), radius: 1mm, fill: bubble, stroke: none)

    // Lanes through W, ending in arrows out of the bubble. The W boxes and add
    // nodes drawn later cover the lines running through them.
    for j in range(3) {
      let x = lane(j)
      draw.line((x, top), (x, py), stroke: streamstroke)
      draw.line((x, py - pr), (x, bottom), stroke: streamstroke, mark: arrowhead)
    }

    // Cross-stream mixing through the sum node, passing over the lanes: a
    // bubble-colored halo under each mixing line breaks the lanes it crosses.
    // Lines leave the A boxes and enter the B boxes vertically, and end in
    // arrowheads at the B boxes.
    let stub = 1.5mm
    let mixing = (
      range(3).map(j => (((ax.at(j), ay - bh), (ax.at(j), ay - bh - stub), (sx, sy)), none))
      + range(3).map(j => (((sx, sy), (ax.at(j), by + stub), (ax.at(j), by)), arrowhead))
    )
    for (pts, _) in mixing {
      draw.line(..pts, stroke: bubble + 1mm)
    }
    for (pts, mark) in mixing {
      draw.line(..pts, stroke: streamstroke, mark: mark)
    }

    // LoRA branches off and back onto each lane.
    for (j, (name, c)) in (([source], streamcolors.at(0)), ([mask], streamcolors.at(1)), ([out], streamcolors.at(2))).enumerate() {
      let x = ax.at(j)
      let l = lane(j)
      draw.circle((l, jy), radius: 0.35mm, fill: black, stroke: none)
      draw.line((l, jy), (x, jy), (x, ay), stroke: streamstroke)
      draw.line((x, by - bh), (x, py), (l, py), stroke: streamstroke)

      matrix(l, ay, white, text(size: 5.5pt)[_W_])
      matrix(x, ay, c, [_A_#sub(name)])
      matrix(x, by, c, [_B_#sub(name)])

      draw.circle((l, py), radius: pr, stroke: layerstroke, fill: white)
      draw.line((l - pr*0.55, py), (l + pr*0.55, py), stroke: streamstroke)
      draw.line((l, py - pr*0.55), (l, py + pr*0.55), stroke: streamstroke)
    }
    draw.circle((sx, sy), radius: sr, stroke: layerstroke, fill: white)
    draw.content((sx, sy), text(font: "STIX Two Math", size: 6pt, top-edge: "bounds", bottom-edge: "bounds", sym.sum))
  }
}))

#let legendpill(fill) = box(width: 8mm, height: lh, radius: lh/2, stroke: layerstroke, fill: fill, baseline: 25%)
#v(1mm)
#align(center, text(size: 9pt)[
  #legendpill(white) #h(1mm) Base Layer #h(6mm) #legendpill(teamworkgrad) #h(1mm) Teamwork-Adapted Layer
])
