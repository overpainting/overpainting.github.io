// Values twyla's `asset.js` substitutes at build time.
interface ImportMeta {
  readonly env: {
    /** Prefix of every twyla URL, with a trailing slash. */
    readonly BASE_URL: string;
  };
}
