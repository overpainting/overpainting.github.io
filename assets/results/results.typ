#import "../theme.typ": *
// Website: full text width (the CVPR paper sets this figure in one column).
#set page(..figpage(textwidth, bottom: 0.5mm))
#set text(..textstyle)

#let overhang = 0.5mm
// leave room for the first row's masks overhanging the last image
#let w = imwidth(5, col: false) - overhang/5
#let mw = 0.4*w

// Prompt over a two-image span, on one line; one that doesn't fit overhangs both sides equally.
// Website: full-size prompt text, which fits the wider span (the paper's single column needs 6pt).
#let prompt(id) = context {
  let t = text(style: "italic")["#read(id + ".prompt.txt").trim()"]
  box(width: measure(t).width, t)
}

// One row per input image: four cases, the first two sharing one prompt and the last two another.
#let items = (
  ("roundrock_left_moss", "roundrock_top_moss", "roundrock_spiral_paint", "roundrock_left_paint"),
  ("bookstack_apple_fuzz", "bookstack_bowl_fuzz", "bookstack_bowl_gems", "bookstack_apple_gems"),
  ("stonewindow_bird_flames", "stonewindow_forest_flames", "stonewindow_right_vines", "stonewindow_top_vines"),
  ("coffeepot_shallow_coffee", "coffeepot_deep_coffee", "coffeepot_spout_steam", "coffeepot_table_steam"),
  ("trevifountain_statue_gold", "trevifountain_arch_gold", "trevifountain_rock_ferns", "trevifountain_cap_ferns"),
)

#grid(
  column-gutter: gutter,
  row-gutter: (labelgap, gutter) * items.len(),
  columns: (w,) * 5,
  ..items.enumerate().map(((row, ids)) => (
    grid.cell[],
    grid.cell(colspan: 2, align: center + bottom, inset: 0.5mm, prompt(ids.at(0))),
    grid.cell(colspan: 2, align: center + bottom, inset: 0.5mm, prompt(ids.at(2))),
    imframe(ids.at(0) + ".input.webp", width: w),
    ..ids.map(i => [
      #imframe(i + ".ours.webp", width: w)
      #let side = if row == 0 { right } else { left }  // first row: masks lower-right
      #place(bottom + side, dx: if side == left { -overhang } else { overhang }, dy: overhang, imframe(i + ".mask.webp", width: mw))
    ]),
  )).flatten()
)
