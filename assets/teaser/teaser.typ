#import "../theme.typ": *
#set page(width: textwidth, height: auto, margin: linestroke, fill: none)
#set text(..textstyle)
#import "@preview/cetz:0.3.4": canvas, draw

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: rect, chevron, pill

#let count = 6
#let mw = 10mm
#let gap = gutter*2
#let iw = (textwidth - gap * (count - 1) - 8pt) / count
#let x(i) = (iw + gap) * (i + 1)
#let imnode(pos, img, width) = node(pos, image(img, width: width), shape: rect, inset: 0pt, stroke: 2*linestroke)

#let prompts = (
  "wavy detailed teal jade stone surface",
  "full of espresso",
  "decorative gold metal bands",
  "covered in wavy silk fabric with a purple sheen",
  "whispy cloud of faint steam",
)

#align(center, canvas({
  draw.rect((0, 0), (rel: (iw, iw)), name: "img", stroke: black + 2*linestroke)
  draw.content("img", image("input.webp", width: iw))
  for (i, n)  in ("1", "2", "3", "4", "5").enumerate() {
    // draw.content((x(i - 1) + iw + gap / 2, iw + gutter), ["#prompts.at(i - 1)"], anchor: "center")
    let prompt = box(align(center, text(size: 7pt, style: "italic")["#prompts.at(i)"]), width: iw + 1.5 * gutter)
    draw.content((x(i) + iw / 2, iw + gutter/2), prompt, anchor: "south")
    draw.line((x(i - 1) + iw, iw/2), (x(i), iw/2), stroke: linestroke, mark: (end: ">", fill: black))
    draw.rect((x(i), 0), (rel: (iw, iw)), name: "img", stroke: black + 2*linestroke)
    draw.content("img", image("edit" + n + ".png", width: iw))
    //draw.rect((x(i - 1) + iw + gutter, iw - mw), (rel: (mw, mw)), name: "mask", stroke: black + 2*linestroke)
    //draw.content("mask", image("mask" + str(i) + ".webp", width: mw))
    draw.rect((x(i) + iw - mw + 1mm, -1mm), (rel: (mw, mw)), name: "mask", stroke: black + 2*linestroke)
    draw.content("mask", image("mask" + n + ".png", width: mw))
  }
}))
