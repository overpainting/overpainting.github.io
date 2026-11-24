// Sliding-mask figure: the mask follows the pointer over a panel; otherwise it moves up and down its column,
// one grid row at a time, turning around at the top and bottom rows.

// The grid data is bundled from the JSON file rather than passed through typst, whose `json()` decodes floats
// into dictionaries in twyla (rolldown turns on serde_json's `arbitrary_precision`).
import data from "../data/maskgrid.json";

/** One `data/maskgrid.json` entry; geometry in fractions of the (square) image side. */
interface MaskGrid {
  name: string; // images under `maskgrid/<name>/`, panel `data-name`
  prompt: string;
  stems: string[][]; // [row][col]
  start: [number, number]; // (col, row) shown first: the drawn column, the row nearest the image's middle
  rows: [number, number]; // first and last row of the bounce
  origin: [number, number]; // white centroid at (col, row) = (0, 0)
  step: number; // grid spacing
}

const grids = data as MaskGrid[];

interface PanelState {
  grid: MaskGrid;
  col: number;
  row: number; // continuous while bouncing; rounds to the shown row
  dir: 1 | -1;
  hover: boolean;
  wanted: string;
  show(): void;
}

const ROWS_PER_SECOND = 2;
const TOUCH_SCROLL_EDGE = 32; // CSS px

const clamp = (v: number, lo: number, hi: number) => Math.min(hi, Math.max(lo, v));
const files = (grid: MaskGrid, stem: string) => {
  const dir = `${import.meta.env.BASE_URL}maskgrid/${grid.name}`;
  return [`${dir}/${stem}.avif`, `${dir}/${stem}.trimap.png`];
};

const panels = [...document.querySelectorAll<HTMLElement>(".maskgrid-panel")];

if (panels.length) {
  const reducedMotion = matchMedia("(prefers-reduced-motion: reduce)");

  const states = panels.map((panel): PanelState => {
    const grid = grids.find((g) => g.name === panel.dataset.name)!;
    const result = panel.querySelector<HTMLImageElement>(".maskgrid-result")!;
    const trimap = panel.querySelector<HTMLImageElement>(".maskgrid-trimap")!;
    const [nx, ny] = [grid.stems[0].length, grid.stems.length];
    const s: PanelState = {
      grid,
      col: grid.start[0],
      row: grid.start[1],
      dir: 1,
      hover: false,
      wanted: grid.stems[grid.start[1]][grid.start[0]],
      // Swap both images only once both are decoded, so the panel never flashes empty.
      show() {
        const stem = grid.stems[clamp(Math.round(s.row), 0, ny - 1)][s.col];
        if (stem === s.wanted) return;
        s.wanted = stem;
        const images = files(grid, stem).map((src) => Object.assign(new Image(), { src }));
        Promise.all(images.map((image) => image.decode())).then(
          () => {
            if (s.wanted !== stem) return;
            result.src = images[0].src;
            trimap.src = images[1].src;
          },
          () => {},
        );
      },
    };
    const follow = (event: PointerEvent) => {
      const rect = panel.getBoundingClientRect();
      const x = clamp((event.clientX - rect.left) / rect.width, 0, 1);
      const y = clamp((event.clientY - rect.top) / rect.height, 0, 1);
      s.col = clamp(Math.round((x - grid.origin[0]) / grid.step), 0, nx - 1);
      s.row = clamp(Math.round((y - grid.origin[1]) / grid.step), 0, ny - 1);
      s.hover = true;
      s.show();
    };
    for (const type of ["pointerenter", "pointermove", "pointerdown"] as const) panel.addEventListener(type, follow);
    // A touch starting inside the panel drags the mask instead of scrolling the page; one starting within
    // TOUCH_SCROLL_EDGE of a side (or off the panel) still scrolls. Cancelling the touchstart keeps the
    // pointer events flowing, implicitly captured to the panel until the finger lifts.
    panel.addEventListener(
      "touchstart",
      (event) => {
        if (event.touches.length !== 1) return;
        const { clientX: x, clientY: y } = event.touches[0];
        const rect = panel.getBoundingClientRect();
        const edge = Math.min(x - rect.left, rect.right - x, y - rect.top, rect.bottom - y);
        if (edge >= TOUCH_SCROLL_EDGE) event.preventDefault();
      },
      { passive: false },
    );
    // Bouncing resumes from the pointer's last position, in its column.
    panel.addEventListener("pointerleave", () => {
      s.hover = false;
    });
    return s;
  });

  let last: number | null = null;
  const step = (now: number) => {
    const dt = last === null ? 0 : Math.min(0.05, (now - last) / 1000);
    last = now;
    if (!reducedMotion.matches) {
      for (const s of states) {
        if (s.hover) continue;
        const [top, bottom] = s.grid.rows;
        // Turn around at an end row (and head back if the pointer left the mask beyond one).
        if (s.row >= bottom) s.dir = -1;
        else if (s.row <= top) s.dir = 1;
        s.row += s.dir * ROWS_PER_SECOND * dt;
        s.show();
      }
    }
    requestAnimationFrame(step);
  };
  requestAnimationFrame(step);

  // After the page loads, fetch every position a few at a time (each panel's start column first, then by
  // distance from its start, panels interleaved), so pointing and bouncing rarely wait on the network.
  const prefetch = () => {
    const queue = states
      .flatMap(({ grid }) =>
        grid.stems.flatMap((row, iy) =>
          row.map((stem, ix) => ({
            grid,
            stem,
            d: (ix === grid.start[0] ? 0 : 1000) + Math.hypot(ix - grid.start[0], iy - grid.start[1]),
          })),
        ),
      )
      .sort((a, b) => a.d - b.d)
      .flatMap(({ grid, stem }) => files(grid, stem));
    let next = 0;
    const fetchNext = () => {
      if (next >= queue.length) return;
      const image = new Image();
      image.onload = image.onerror = fetchNext;
      image.src = queue[next++];
    };
    for (let k = 0; k < 6; k++) fetchNext();
  };
  if (document.readyState === "complete") prefetch();
  else window.addEventListener("load", prefetch);
}
