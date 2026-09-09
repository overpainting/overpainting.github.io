# Overpainting project website

This is a two-page Twyla site for `https://overpainting.github.io`:

- `/` is the paper landing page.
- `/results/` is the exhaustive comparison grid generated from `data/cases.csv`.

The result grid loads images directly from `raw.githubusercontent.com`; those files are not copied into the site output.

## Build locally

From this directory, build the site with:

```sh
twyla build
```

For local development with live reload, run:

```sh
twyla serve
```

To refresh the vendored manuscript figures and test-set metadata:

```sh
./sync-paper-assets.sh /path/to/Overpainting-submission
```

The figure `.typ` sources are compiled to SVGs by Twyla during the site build. The teaser social-preview image remains a high-resolution PNG.

## Editorial handoff

The abstract and short technical descriptions are adapted directly from the manuscript. Before publication, review the small amount of connective copy in `content/main.typ`, add the arXiv/code/model links, and add the author list when ready.

## GitHub Pages

The workflow in `.github/workflows/pages.yml` builds from the repository root and publishes `public`. For the root URL `https://overpainting.github.io`, GitHub requires this repository to be named `overpainting.github.io`; otherwise GitHub will serve it as a project site under the repository name and the build's base URL should include that path.
