#import "/templates/site.typ": *

#set document(
  title: "Overpainting: Localized Context-aware Diffusion Image Editing",
  description: "A diffusion-based method for localized, context-aware image editing with trimap control.",
)

#show: body => context {
  let preview = asset.typst(
    "/assets/teaser/teaser.typ",
    format: "png",
    ppi: 288,
  ).url()
  page-shell(
    "Overpainting: Localized Context-aware Diffusion Image Editing",
    "A diffusion-based method for localized, context-aware image editing with trimap control.",
    body,
    preview: preview,
  )
}

#show heading.where(level: 2): project-heading
#show figure: project-figure

// Sliding-mask figure, driven by /scripts/maskgrid.ts: one panel per grid in /data/maskgrid.json, its
// images under /static/maskgrid/<name>/.
#let maskgrid-size = "512"
#let maskgrid-panels(grids) = html.div(class: "maskgrid-panels", for g in grids {
  let dir = base-url + "/maskgrid/" + g.name
  let stem = g.stems.at(g.start.at(1)).at(g.start.at(0))
  // Only strings and integers are read here: the script imports the JSON itself (see there for why).
  html.elem("div", attrs: (class: "maskgrid-panel", "data-name": g.name), {
    html.elem("img", attrs: (
      class: "maskgrid-result",
      src: dir + "/" + stem + ".avif",
      width: maskgrid-size,
      height: maskgrid-size,
      fetchpriority: "high",
      decoding: "async",
      alt: "Overpainting result for “" + g.prompt + "”",
    ))
    html.div(class: "maskgrid-inset", html.elem("img", attrs: (
      class: "maskgrid-trimap",
      src: dir + "/" + stem + ".trimap.png",
      width: maskgrid-size,
      height: maskgrid-size,
      decoding: "async",
      alt: "Trimap",
    )))
  })
})

#html.elem("header", attrs: (class: "hero"), {
  html.h1[Overpainting]
  html.p(class: "subtitle")[Localized Context-aware Diffusion Image Editing]
  html.div(class: "pills", {
    pill("arXiv", href: "https://arxiv.org/abs/2609.10811", target: "_self")
    pill("Code", note: "Coming soon")
    pill("Model", note: "Coming soon")
    pill("Test set", href: "https://github.com/overpainting/overpainting-evaluation/blob/main/testset/cases.csv")
    pill("All results", href: base-url + "/results/", target: "_self")
  })
})

#html.div(class: "teaser")[
  #figure(
    paper-image(
      "/assets/teaser/teaser.typ",
      "A source image followed by five localized overpainting edits, each with a trimap inset.",
    ),
    caption: [
      A sequence of localized overpainting edits.
    ],
  )

  #figure(
    maskgrid-panels(json("/data/maskgrid.json")),
    caption: [
      An example of Overpainting edits with the same trimap moved to different
      locations. Hover to interact.
    ],
  )
]

#html.elem("section", attrs: (class: "section narrow", id: "abstract"))[
== Abstract

We present “overpainting”, an image editing operation which offers both control
over the location of the edit and awareness of the previous content in that
location. The overpainted area is specified by a trimap, where white-annotated
pixels must be edited, gray-annotated pixels may be edited, and black-annotated
pixels must not be edited. This enables both precise and loose control,
depending on user intent.

We implement overpainting by adapting a pretrained image editing diffusion
model by augmenting the pretrained models' native joint-attention with a
variant of Teamwork that performs low-rank adaptation across image-streams
and that balances information flow between noise, source, and trimap mask
images. Furthermore, we present a novel, automated, training data generation
pipeline that (1) generates a set of candidate image pairs leveraging existing
language-based editing models, (2) carefully curates those pairs, and (3)
extracts a trimap from each usable pair. We demonstrate the versatility of our
overpainting model on a wide range of editing tasks.
]

#html.elem("section", attrs: (class: "section", id: "method"))[
== Trimap control

Specifying an exact editing mask
around existing image features is cumbersome and error-prone (#eg, for
thin features or precise object boundaries). It is also often
ambiguous for edits with ill-defined boundaries (#eg, frost forming on
a window or smoke dissipating) and for to-be-created features whose
location depends on the target edit itself (#eg, whiskers protruding
from an object on which the user asked the model to grow hair). We
tackle this challenge by introducing a trimap that marks not only pixels
which _must_ be edited #html.span(class: "swatch white")[ ] and _must not_ be edited #html.span(class: "swatch black")[ ], but also
pixels that _may or may not_ be edited #html.span(class: "swatch gray")[ ].

#figure(
  paper-image(
    "/assets/maskvariations/maskvariations.typ",
    "The same source edited with several precise and approximate trimaps.",
  ),
  caption: [
    Adding _"shaggy purple fur"_ to an apple requires
    a detailed binary mask (2nd column); without a detailed mask,
    the protruding whiskers of fur will be missing (3rd column).
    Marking a whole region as may-edit #html.span(class: "swatch gray")[ ],
    alleviates the user from specifying a precise mask (4th column).
    By combining both white #html.span(class: "swatch white")[ ] and
    gray #html.span(class: "swatch gray")[ ] regions, the user caan create both
    precise and loose boundaries in the same image (5th column).
  ],
)

== Data Generation

To train our overpainting model we require paired data in the form of an
original image, an edited version, a mask, and a prompt describing the edit
operation. We follow the well-established process of leveraging VLMs and image
diffusion models to generate training data. Specifically, we:
+ randomly sample freely licensed photographs from #link("https://pexels.com")[pexels.com] as source photographs
+ use #link("https://huggingface.co/Qwen/Qwen3-30B-A3B-Instruct-2507")[Qwen3 Instruct] to suggest edit prompts
+ feed the source images and generated prompts into #link("https://huggingface.co/black-forest-labs/FLUX.2-klein-9B")[FLUX.2 Klein] or #link("https://huggingface.co/Qwen/Qwen-Image-2.1")[Qwen Image 2.1] to produce edited photographs
+ filter out over-edited, under-edited, and misaligned results
+ estimate which pixels were actually edited using an adapted #link("https://huggingface.co/ZhengPeng7/BiRefNet")[BiRefNet] finetune
+ degrade the precise binary masks into human-like trimaps

#figure(
  paper-image(
    "/assets/pipeline/pipeline_flat.png",
    "Overview of the training data generation pipeline.",
    ppi: 300, // Illustrator export resolution
  ),
  caption: [
    Overview of the training data generation pipeline.
  ],
)

== Finetuning

We demonstrate overpainting by finetuning
#link("https://arxiv.org/abs/2510.05532")[Teamwork LoRAs] for the
#link("https://huggingface.co/black-forest-labs/FLUX.2-klein-9B")[FLUX.2 Klein] and
#link("https://huggingface.co/Qwen/Qwen-Image-2.1")[Qwen Image 2.1] models.
The image editing diffusion models accept a prompt, latents for any number of condition images, and noisy
latents for the image to generate. We provide both the source image and trimap
image as VAE-encoded conditions.

Empirically we found that a naive LoRA-adapted model adhears poorly to the
user-provided trimap. By using a Teamwork LoRA, we impose a strong positional
bias (#ie, edited image latents at a particular position exchange information
directly with the correspoinding source latents and mask latents). On the other
hand, Teamwork alone allows limited global reasoning, and so provides poor
edit quality. We therefore use _both_ the attention of the base editing model and
the aggredation of the Teamwork LoRAs.

#figure(
  paper-image(
    "/assets/arch/arch.typ",
    "Architecture overview.",
  ),
  caption: [
    Architecture overview. We pass the source image
    and trimap as additional condition images, and communicate
    across the conditions and the noise using both teamwork and
    joint attention.
  ],
)

]

#html.elem("section", attrs: (class: "section", id: "examples"))[
== Examples

A range of localized edits from the paper.
#html.a(class: "text-link", href: base-url + "/results/")[Browse all 180 comparisons →]

#figure(
  paper-image(
    "/assets/results/results.typ",
    "Selected overpainting results showing sources, prompts, trimaps, and edited outputs.",
  ),
  caption: [Selected overpainting results showing the source, prompt, trimap, and edited output.],
)
]

#html.elem("section", attrs: (class: "section release-card"))[
== Resources

Model outputs on our test set are avalible now. Source code and checkpoints will be made
available once published.

#html.div(class: "pills", {
  pill("Raw test set", href: "https://github.com/overpainting/overpainting-evaluation/blob/main/testset/cases.csv")
  pill("Raw result images", href: "https://github.com/overpainting/overpainting-evaluation/tree/main")
  pill("Result viewer", href: base-url + "/results/", target: "_self")
})
]

#context html.script(type: "module", src: asset.js("/scripts/maskgrid.ts").url())
