#import "../theme.typ": *
#set page(width: textwidth, height: auto, margin: (bottom: 4mm, rest: 0mm), fill: none)
#set text(..textstyle)

#let w = (textwidth - gutter*4 - 1pt*5)/5

#let sq(body) = rect(align(text(body, size: 20pt), center + horizon), width: w, height: w, ..linestyle)
#let items = ("round_stone", "apple_bowl", "bird_window", "coffee_pot", "trevi")

#align(center, grid(
  column-gutter: gutter,
  row-gutter: (1mm, gutter) * items.len(),
  columns: 5,
  ..items.map(i => (
    grid.cell[],
    grid.cell(colspan: 2, align: center, inset: 1mm)["#text(read(i + ".prompt1.txt").trim(), style: "italic")"],
    grid.cell(colspan: 2, align: center, inset: 1mm)["#text(read(i + ".prompt2.txt").trim(), style: "italic")"],
    imframe(i + ".input.webp", width: w),
    ..range(1,5).map(j => [
      #imframe(i + ".output" + str(j) + ".webp", width: w)
      #place(bottom + left, dx: -1mm, dy: 1mm, imframe(i + ".mask" + str(j) + ".webp", width: 12mm))
    ]),
  )).flatten()
))
