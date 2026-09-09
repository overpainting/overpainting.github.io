(() => {
  const grid = document.getElementById("resultsGrid");
  const buttons = [...document.querySelectorAll(".view-controls .view-btn[data-view]")];
  const images = [...document.querySelectorAll(".switchable-result img")];
  const lightboxTargets = [...document.querySelectorAll("img[data-lightbox]")];

  if (!grid || buttons.length === 0 || images.length === 0 || lightboxTargets.length === 0) return;

  let selectedView = "edited";
  let keyOverride = null;
  let lightboxTarget = null;
  let selectedLightboxView = null;
  let returnFocus = null;

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

  const lightboxImage = lightbox.querySelector(".lightbox-stage img");
  const lightboxButtons = [...lightbox.querySelectorAll("[data-lightbox-view]")];
  const closeButton = lightbox.querySelector(".lightbox-close");

  const sourceFor = (image, view) => image?.dataset[view] || "";
  const altFor = (image, view) => image?.dataset[`${view}Alt`] || image?.alt || "Image preview";

  const updateLightbox = (view, persist = false) => {
    if (!lightboxTarget || !sourceFor(lightboxTarget, view)) return;
    if (persist) selectedLightboxView = view;
    lightboxImage.src = sourceFor(lightboxTarget, view);
    lightboxImage.alt = altFor(lightboxTarget, view);
    lightbox.classList.toggle("view-mask", view === "mask");
    lightboxButtons.forEach((button) => {
      const buttonView = button.dataset.lightboxView;
      const available = Boolean(sourceFor(lightboxTarget, buttonView));
      const active = buttonView === view;
      button.disabled = !available;
      button.classList.toggle("active", active);
      button.setAttribute("aria-pressed", String(active));
    });
  };

  const openLightbox = (image) => {
    lightboxTarget = image;
    returnFocus = image;
    const displayedView = image.dataset.lightboxView || selectedView;
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

  const updateView = (view) => {
    grid.classList.remove("view-original", "view-edited", "view-mask");
    grid.classList.add(`view-${view}`);

    images.forEach((image) => {
      const src = image.dataset[view];
      const alt = image.dataset[`${view}Alt`];
      if (src) {
        image.src = src;
        image.dataset.lightboxView = view;
      }
      if (alt) image.alt = alt;
    });
  };

  const updateButtons = () => {
    buttons.forEach((button) => {
      const active = button.dataset.view === selectedView;
      button.classList.toggle("active", active);
      button.setAttribute("aria-pressed", String(active));
    });
  };

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      selectedView = button.dataset.view;
      updateButtons();
      if (!keyOverride) updateView(selectedView);
    });
  });

  lightboxButtons.forEach((button) => {
    button.addEventListener("click", () => updateLightbox(button.dataset.lightboxView, true));
  });

  lightboxTargets.forEach((image) => {
    image.addEventListener("click", () => openLightbox(image));
    image.addEventListener("keydown", (event) => {
      if (event.key === "Enter" || event.key === " ") {
        event.preventDefault();
        openLightbox(image);
      }
    });
  });

  lightbox.querySelector(".lightbox-backdrop").addEventListener("click", closeLightbox);
  closeButton.addEventListener("click", closeLightbox);

  const keyMap = { o: "original", e: "edited", m: "mask" };

  document.addEventListener("keydown", (event) => {
    if (event.repeat || event.metaKey || event.ctrlKey || event.altKey) return;
    const view = keyMap[event.key.toLowerCase()];
    if (view && !keyOverride) {
      keyOverride = view;
      updateView(view);
      updateLightbox(view);
    }
  });

  document.addEventListener("keyup", (event) => {
    const view = keyMap[event.key.toLowerCase()];
    if (view && keyOverride === view) {
      keyOverride = null;
      updateView(selectedView);
      if (lightboxTarget) updateLightbox(selectedLightboxView);
    }
  });

  window.addEventListener("blur", () => {
    if (keyOverride) {
      keyOverride = null;
      updateView(selectedView);
      if (lightboxTarget) updateLightbox(selectedLightboxView);
    }
  });

  const helpButtons = [...document.querySelectorAll(".method-help-button")];

  const closeHelp = (except = null) => {
    helpButtons.forEach((button) => {
      if (button !== except) {
        button.closest(".method-help").classList.remove("open");
        button.setAttribute("aria-expanded", "false");
      }
    });
  };

  helpButtons.forEach((button) => {
    button.addEventListener("click", (event) => {
      event.stopPropagation();
      const help = button.closest(".method-help");
      const opening = !help.classList.contains("open");
      closeHelp(button);
      help.classList.toggle("open", opening);
      button.setAttribute("aria-expanded", String(opening));
    });
  });

  document.addEventListener("click", (event) => {
    if (!event.target.closest(".method-help")) closeHelp();
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      closeLightbox();
      closeHelp();
    }
  });
})();
