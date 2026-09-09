#import "/templates/site.typ": *

#set document(
  title: "Overpainting — Results",
  description: "Exhaustive qualitative comparisons across the 180-case Overpainting test set.",
)

#show: body => page-shell(
  "Overpainting — Results",
  "Exhaustive qualitative comparisons across the 180-case Overpainting test set.",
  body,
  current: "results",
)

#let repository = "https://github.com/overpainting/overpainting-evaluation"
#let raw-root = "https://raw.githubusercontent.com/overpainting/overpainting-evaluation/main"

// This list alone controls which result columns appear in the comparison.
#let methods = (
  (
    label: "Overpainting",
    path: "overpainting_v1_50",
    hint: [Our overpainting model used to generate all results in the main paper. It strikes a good balance between edit quality and mask adherence.],
  ),
  (
    label: "FLUX+LoRA",
    path: "overpainting_v1_lora",
    hint: [A LoRA adapted joint attention model trained on our overpainting dataset. Pure joint attention achieves high marks on quality, but underperforms in mask adherence.],
  ),
  (
    label: "Nano Banana",
    path: "nanobanana_prompt",
    hint: [Nano Banana with detailed prompt, where the prompt includes additional details to describe the location of the edits.],
  ),
  (
    label: "UltraEdit",
    path: "ultraedit",
    hint: [#link("https://arxiv.org/abs/2407.05282")[UltraEdit]: a prior local image editing model.],
  ),
  (
    label: "SDEdit",
    path: "sdedit_flux",
    hint: [#link("https://sde-image-editing.github.io/")[SDEdit] with FLUX.1 Dev is capable of making local edits, but it ignores the underlying image content, and requires careful fine-tuning of hyper-parameters to balance identity-preservation and editing strength.],
  ),
  (
    label: "FLUX Fill",
    path: "flux_fill",
    hint: [#link("https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev")[FLUX Fill]: An inpainting model that ignores the underlying image content and has trouble using the entire edited area.],
  ),
)

#let cases = csv("/data/cases.csv", row-type: dictionary)

#let image-cell(src, alt, original, mask, view, class: "") = html.div(
  class: "result-cell " + class,
  html.elem("img", attrs: (
    src: src,
    alt: alt,
    loading: "lazy",
    decoding: "async",
    tabindex: "0",
    role: "button",
    "aria-label": "Open larger: " + alt,
    "data-lightbox": "",
    "data-lightbox-view": view,
    "data-original": original,
    "data-mask": mask,
    "data-original-alt": "Original image for this edit",
    "data-mask-alt": "Trimap for this edit",
  )),
)

#let switchable-image-cell(edited, original, mask, alt) = html.div(
  class: "result-cell switchable-result",
  html.elem(
    "img",
    attrs: (
      src: edited,
      alt: alt,
      loading: "lazy",
      decoding: "async",
      tabindex: "0",
      role: "button",
      "aria-label": "Open larger: " + alt,
      "data-lightbox": "",
      "data-lightbox-view": "edited",
      "data-edited": edited,
      "data-original": original,
      "data-mask": mask,
      "data-edited-alt": alt,
      "data-original-alt": "Original image for this edit",
      "data-mask-alt": "Trimap for this edit",
    ),
  ),
)

#let method-heading(method) = html.div(class: "column-heading", {
  html.span(method.label)
  html.div(class: "method-help", {
    html.elem("button", attrs: (
      type: "button",
      class: "method-help-button",
      "aria-label": "About " + method.label,
      "aria-expanded": "false",
    ))[?]
    html.div(class: "method-tooltip", method.hint)
  })
})

#html.elem("header", attrs: (class: "results-hero"), {
  html.h1[All results]
  html.p[
    Exhaustive qualitative comparisons on our 180 human-authored test cases.
  ]
  html.div(class: "pills", {
    pill("Raw test set", href: repository + "/blob/main/testset/cases.csv")
    pill("Raw result images", href: repository + "/tree/main")
  })
})

#html.elem("div", attrs: (
  class: "results-viewer",
  style: "--table-min-width: " + str(392 + methods.len() * 218) + "px",
), {
  html.elem("div", attrs: (class: "results-note view-controls", "aria-label": "Image view"), {
    for item in (
      (view: "original", label: "Original"),
      (view: "edited", label: "Edited"),
      (view: "mask", label: "Mask"),
    ) {
      html.elem("button", attrs: (
        type: "button",
        class: "view-btn" + if item.view == "edited" { " active" } else { "" },
        "data-view": item.view,
        "aria-pressed": if item.view == "edited" { "true" } else { "false" },
      ), item.label)
    }
    html.span(class: "view-hint")[Hold O / E / M to preview]
  })

  html.elem("div", attrs: (
    class: "results-table view-edited",
    id: "resultsGrid",
    style: "--columns: " + str(methods.len()),
  ), {
    html.div(class: "results-row results-header", {
      html.elem("div", attrs: ("aria-hidden": "true"))[]
      for method in methods { method-heading(method) }
    })

    for case in cases {
      let input-url = raw-root + "/testset/" + case.source_image
      let mask-url = raw-root + "/testset/" + case.mask_image
      html.elem("article", attrs: (class: "results-row"), {
        html.div(class: "case-overview", {
          html.p(class: "case-prompt", "“" + case.prompt + "”")
          html.div(class: "case-references", {
            image-cell(input-url, "Input image for " + case.prompt, input-url, mask-url, "original")
            image-cell(mask-url, "Trimap for " + case.prompt, input-url, mask-url, "mask", class: "mask-cell")
          })
        })
        for method in methods {
          let result-url = raw-root + "/" + method.path + "/" + case.id + "_seed42.jpg"
          switchable-image-cell(
            result-url,
            input-url,
            mask-url,
            method.label + " result for " + case.prompt,
          )
        }
      })
    }
  })
})

#html.elem("script", attrs: (
  src: base-url + "/scripts/results.js",
  defer: "",
))[]
