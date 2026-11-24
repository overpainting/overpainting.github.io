// Results viewer: original/edited/mask view switching (buttons or held O/E/M keys), a lightbox, and method
// help tooltips. Images only swap source while on screen, so switching views doesn't refetch the whole table.

type View = "original" | "edited" | "mask";

const keyMap: Record<string, View> = { o: "original", e: "edited", m: "mask" };

const grid = document.getElementById("resultsGrid");
const buttons = [...document.querySelectorAll<HTMLButtonElement>(".view-controls .view-btn[data-view]")];
const images = [...document.querySelectorAll<HTMLImageElement>(".switchable-result img")];
const lightboxTargets = [...document.querySelectorAll<HTMLImageElement>("img[data-lightbox]")];

if (grid && buttons.length && images.length && lightboxTargets.length) {
  let selectedView: View = "edited";
  let keyOverride: View | null = null;
  let lightboxTarget: HTMLImageElement | null = null;
  let selectedLightboxView: View | null = null;
  let returnFocus: HTMLElement | null = null;
  const visibleImages = new Set<HTMLImageElement>();

  const lightbox = document.createElement("div");
  lightbox.className = "result-lightbox";
  lightbox.hidden = true;
  lightbox.setAttribute("role", "dialog");
  lightbox.setAttribute("aria-modal", "true");
  lightbox.setAttribute("aria-label", "Image preview");
  lightbox.innerHTML = `
    <button class="lightbox-backdrop" type="button" aria-label="Close image preview"></button>
    <div class="lightbox-panel">
      <div class="lightbox-toolbar">
        <div class="lightbox-view-controls" aria-label="Preview image view">
          <button class="view-btn" type="button" data-lightbox-view="original">Original</button>
          <button class="view-btn" type="button" data-lightbox-view="edited">Edited</button>
          <button class="view-btn" type="button" data-lightbox-view="mask">Mask</button>
          <span class="view-hint">Hold O / E / M to preview</span>
        </div>
        <button class="lightbox-close" type="button" aria-label="Close image preview">&times;</button>
      </div>
      <div class="lightbox-stage"><img alt=""></div>
    </div>`;
  document.body.append(lightbox);

  const lightboxImage = lightbox.querySelector<HTMLImageElement>(".lightbox-stage img")!;
  const lightboxButtons = [...lightbox.querySelectorAll<HTMLButtonElement>("[data-lightbox-view]")];
  const closeButton = lightbox.querySelector<HTMLButtonElement>(".lightbox-close")!;

  const sourceFor = (image: HTMLImageElement | null, view: View) => image?.dataset[view] || "";

  const updateLightbox = (view: View | null, persist = false) => {
    if (!view || !lightboxTarget || !sourceFor(lightboxTarget, view)) return;
    if (persist) selectedLightboxView = view;
    lightboxImage.src = sourceFor(lightboxTarget, view);
    lightboxImage.alt = lightboxTarget.dataset[`${view}Alt`] || lightboxTarget.alt || "Image preview";
    lightbox.classList.toggle("view-mask", view === "mask");
    for (const button of lightboxButtons) {
      const buttonView = button.dataset.lightboxView as View;
      const active = buttonView === view;
      button.disabled = !sourceFor(lightboxTarget, buttonView);
      button.classList.toggle("active", active);
      button.setAttribute("aria-pressed", String(active));
    }
  };

  const openLightbox = (image: HTMLImageElement) => {
    lightboxTarget = image;
    returnFocus = image;
    const displayedView = (image.dataset.lightboxView as View | undefined) || selectedView;
    lightbox.hidden = false;
    document.body.classList.add("lightbox-open");
    updateLightbox(sourceFor(image, displayedView) ? displayedView : "original", true);
    closeButton.focus();
  };

  const closeLightbox = () => {
    if (lightbox.hidden) return;
    lightbox.hidden = true;
    document.body.classList.remove("lightbox-open");
    lightboxImage.removeAttribute("src");
    lightboxTarget = null;
    selectedLightboxView = null;
    returnFocus?.focus();
    returnFocus = null;
  };

  const updateImage = (image: HTMLImageElement, view: View) => {
    const src = image.dataset[view];
    const alt = image.dataset[`${view}Alt`];
    if (src && image.dataset.lightboxView !== view) {
      image.src = src;
      image.dataset.lightboxView = view;
    }
    if (alt) image.alt = alt;
  };

  const updateView = (view: View) => {
    grid.classList.remove("view-original", "view-edited", "view-mask");
    grid.classList.add(`view-${view}`);
    for (const image of visibleImages) updateImage(image, view);
  };

  const imageObserver = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      const image = entry.target as HTMLImageElement;
      if (entry.isIntersecting) {
        visibleImages.add(image);
        updateImage(image, keyOverride || selectedView);
      } else {
        visibleImages.delete(image);
      }
    }
  });
  for (const image of images) imageObserver.observe(image);

  const updateButtons = () => {
    for (const button of buttons) {
      const active = button.dataset.view === selectedView;
      button.classList.toggle("active", active);
      button.setAttribute("aria-pressed", String(active));
    }
  };

  for (const button of buttons) {
    button.addEventListener("click", () => {
      selectedView = button.dataset.view as View;
      updateButtons();
      if (!keyOverride) updateView(selectedView);
    });
  }

  for (const button of lightboxButtons) {
    button.addEventListener("click", () => updateLightbox(button.dataset.lightboxView as View, true));
  }

  for (const image of lightboxTargets) {
    image.addEventListener("click", () => openLightbox(image));
    image.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        openLightbox(image);
      }
    });
  }

  lightbox.querySelector(".lightbox-backdrop")!.addEventListener("click", closeLightbox);
  closeButton.addEventListener("click", closeLightbox);

  document.addEventListener("keydown", (event) => {
    if (event.repeat || event.metaKey || event.ctrlKey || event.altKey) return;
    const view = keyMap[event.key.toLowerCase()];
    if (view && !keyOverride) {
      keyOverride = view;
      updateView(view);
      updateLightbox(view);
    }
  });

  const releaseKey = () => {
    keyOverride = null;
    updateView(selectedView);
    if (lightboxTarget) updateLightbox(selectedLightboxView);
  };

  document.addEventListener("keyup", (event) => {
    const view = keyMap[event.key.toLowerCase()];
    if (view && keyOverride === view) releaseKey();
  });

  window.addEventListener("blur", () => {
    if (keyOverride) releaseKey();
  });

  const helpButtons = [...document.querySelectorAll<HTMLButtonElement>(".method-help-button")];

  const closeHelp = (except: HTMLButtonElement | null = null) => {
    for (const button of helpButtons) {
      if (button !== except) {
        button.closest(".method-help")!.classList.remove("open");
        button.setAttribute("aria-expanded", "false");
      }
    }
  };

  for (const button of helpButtons) {
    button.addEventListener("click", (event) => {
      event.stopPropagation();
      const help = button.closest(".method-help")!;
      const opening = !help.classList.contains("open");
      closeHelp(button);
      help.classList.toggle("open", opening);
      button.setAttribute("aria-expanded", String(opening));
    });
  }

  document.addEventListener("click", (event) => {
    if (!(event.target as Element).closest(".method-help")) closeHelp();
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      closeLightbox();
      closeHelp();
    }
  });
}
