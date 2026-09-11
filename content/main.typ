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
      A sequence of localized overpainting edits. Gray represents areas where
      change may occur and white represents areas where change must occur.
    ],
  )
]

#html.elem("section", attrs: (class: "section narrow", id: "abstract"))[
== Abstract

We present "overpainting", an image editing operation which offers both control
over the location of the edit and awareness of the previous content in that
location. The overpainted area is given by a trimap, where white-annotated
pixels must be edited, gray-annotated pixels may be edited, and black-annotated
pixels must not be edited. This enables both precise and loose control,
depending on user intent.

We implement overpainting by adapting a pretrained image editing diffusion
model using a combination of joint attention and low-rank adaption across input
images with attention-dropout to balance the information flow between noise,
source and mask images. We present a novel, automated, training data generation
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
    Trimap variations on an image of an apple with the prompt _"wrapped in black
    twine"_. The user can place individual twines by drawing thin white lines,
    control some twine placement but also leave the model free to add/remove
    extra, or mark the entire apple white and force the model to cover it
    entirely.
  ],
)

== Data Generation

To train our overpainting model we require paired data in the form of an
original image, an edited version, a mask, and a prompt describing the edit
operation. We follow the well-established process of leveraging VLMs and image
diffusion models to generate training data. Specifically, we:
+ randomly sample freely licensed photographs from #link("https://pexels.com")[pexels.com] as source photographs
+ use #link("https://arxiv.org/abs/2502.13923")[Qwen2.5-VL] to suggest edit prompts
+ feed the source images and generated propts into #link("https://bfl.ai/models/flux-kontext")[FLUX.1 Kontext] to produce edited photographs
+ filter out over-edited, under-edited, and misaligned results
+ estimate which pixels were actually edited using an adapted #link("https://huggingface.co/ZhengPeng7/BiRefNet")[BiRefNet] finetune
+ degrade the precise binary masks into human-like trimaps

#figure(
  paper-image(
    "/assets/pipeline/pipeline.typ",
    "Overview of the training data generation pipeline.",
  ),
  caption: [
    Overview of the training data generation pipeline.
  ],
)

== Finetuning

We demonstrate overpainting by finetuning a
#link("https://arxiv.org/abs/2510.05532")[Teamwork LoRA] for the
#link("https://bfl.ai/models/flux-kontext")[FLUX.1 Kontext] model. Base FLUX
Kontext accepts a prompt, latents for any number of condition images, and noisy
latents for the image to generate. We provide both the source image and trimap
image as VAE-encoded conditions.

Empirically we found that a naive LoRA-adapted model adhears poorly to the
user-provided trimap. By using a Teamwork LoRA, we impose a strong positional
bias (#ie, edited image latents at a particular position exchange information
directly with the correspoinding source latents and mask latents). On the other
hand, Teamwork alone allows limited global reasoning, and so provides poor
edit quality. We therefore use _both_ the attention of the base FLUX model and
the aggredation of the Teamwork LoRAs, and balance between them with attention
dropout during training.

#figure(
  paper-image(
    "/assets/arch/arch.typ",
    "Architecture overview.",
    max-height: 30,
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
