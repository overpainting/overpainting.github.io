#let base-url = sys.inputs.at("base_url", default: "")

#let text-of(body) = if body == none { "" } else { plain-text(body) }

#let head(title, description, preview: none) = context html.elem("head", {
  html.elem("meta", attrs: (charset: "utf-8"))
  html.elem("meta", attrs: (
    name: "viewport",
    content: "width=device-width, initial-scale=1",
  ))
  html.elem("meta", attrs: (name: "description", content: description))
  html.elem("meta", attrs: (property: "og:type", content: "website"))
  html.elem("meta", attrs: (property: "og:title", content: title))
  html.elem("meta", attrs: (property: "og:description", content: description))
  if preview != none {
    html.elem("meta", attrs: (property: "og:image", content: preview))
    html.elem("meta", attrs: (name: "twitter:card", content: "summary_large_image"))
    html.elem("meta", attrs: (name: "twitter:image", content: preview))
  }
  html.elem("meta", attrs: (name: "twitter:title", content: title))
  html.elem("meta", attrs: (name: "twitter:description", content: description))
  html.elem("title", title)
  html.elem("link", attrs: (
    rel: "stylesheet",
    href: asset.sass("/sass/site.scss").url(),
  ))
})

#let nav(current: "home") = html.elem("nav", attrs: (class: "top-nav", "aria-label": "Primary navigation"), {
  html.a(href: base-url + "/", class: "wordmark")[Overpainting]
  html.div(class: "nav-links", {
    html.a(href: base-url + "/#method")[Method]
    html.a(href: base-url + "/#examples")[Examples]
    html.a(href: base-url + "/results/", class: if current == "results" { "active" } else { "" })[All results]
  })
})

#let page-shell(title, description, body, current: "home", preview: none) = {
  set smartquote(enabled: true)
  html.elem("html", attrs: (lang: "en"), {
    head(title, description, preview: preview)
    html.elem("body", attrs: (class: if current == "results" { "results-page" } else { "" }), {
      nav(current: current)
      html.elem("main", body)
    })
  })
}

#let pill(label, href: none, note: none, target: "_blank") = {
  let content = {
    html.span(label)
    if note != none { html.span(class: "pill-note", note) }
  }
  if href == none {
    html.span(class: "pill disabled", content)
  } else {
    html.a(class: "pill", href: href, target: target, content)
  }
}

// Paper figures share one scale (CSS px per figure pt) so their frames and text look alike: a textwidth figure
// page (496pt, `figpage` in assets/theme.typ) fills the 1088px `.paper-figure` content box of the widest layout
// (`$figure-px-per-pt` in sass/site.scss). Each image is declared at the pixel density that gives that scale;
// narrower screens shrink it.
#let figure-px-per-pt = 1088 / 496

// A paper figure: a `.typ` source is rendered by typst at `ppi`; anything else (e.g. an Illustrator PNG) is used
// as is, `ppi` being its export resolution.
#let paper-image(path, alt, ppi: 288) = context {
  let url = if path.ends-with(".typ") { asset.typst(path, format: "png", ppi: ppi) } else { asset.file(path) }.url()
  html.elem("img", attrs: (
    src: url,
    srcset: url + " " + str(ppi / 72 / figure-px-per-pt) + "x",
    alt: alt,
    loading: "lazy",
  ))
}

#let project-heading(it) = html.div(
  class: "section-heading",
  html.elem("h" + str(it.depth), it.body),
)

#let project-figure(it) = html.elem("figure", attrs: (class: "paper-figure"), {
  it.body
  if it.caption != none {
    html.elem("figcaption", attrs: (class: "caption"), it.caption.body)
  }
})

#let eg = [e.g.]
#let ie = [i.e.]
