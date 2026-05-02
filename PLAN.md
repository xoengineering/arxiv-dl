# arxiv-dl plan

CLI + library for downloading arxiv.org papers and metadata into an offline archive.

## Goal (v0.1)

Given an arxiv paper identifier (in any common form), produce a self-contained per-paper folder containing the PDF and structured sidecar metadata files.

## In scope (v0.1)

- arxiv.org only.
- Rate limit: enforce ~1 req / 3s by default (arxiv etiquette). Overridable via `ARXIV_RATE_LIMIT` ENV var (seconds between requests, `0` to disable) and `--rate-limit <seconds>` CLI flag. Precedence: CLI flag > ENV var > default (`3`).
- Input forms:
  - Bare ID: `1512.03385`
  - Prefixed ID: `arXiv:1512.03385`
  - Legacy ID: `cs/0002001`, `alg-geom/9708001`
  - Abstract URL: `https://arxiv.org/abs/1512.03385`
  - PDF URL: `https://arxiv.org/pdf/1512.03385.pdf`
  - HTML URL: `https://arxiv.org/html/2506.15442`
  - Versioned IDs: `1512.03385v2`
- Per-paper artifacts downloaded:
  - **PDF** (`/pdf/<id>.pdf`) — primary paper.
  - **Abstract page** (`/abs/<id>`) — single self-contained HTML.
  - **Full HTML version** (`/html/<id>`) — HTML page + all referenced assets (relative images stay in-folder; same-host `/static/...` and CDN-hosted CSS/JS go to a shared cache; HTML rewritten to point at local files).
  - **TeX/LaTeX source** (`/src/<id>`) — tarball downloaded then extracted into `src/`.
  - **Sidecar metadata** — `metadata.{md,yaml,json,bib}`.
- CLI binary `arxiv-dl` with one or more targets as args.
- Default download path: `$HOME/Downloads/ArXiv_Papers`.
- ENV override: `ARXIV_DOWNLOAD_PATH` (download path), `ARXIV_RATE_LIMIT` (rate limit).
- CLI flag overrides: `-p / --path <path>`, `--rate-limit <seconds>`.
- Output verbosity:
  - **Default** — print the final folder path on success.
  - `-v / --verbose` — `==>` step lines + URLs fetched (with byte counts) + files written.
  - `-q / --quiet` — print nothing; success/failure conveyed via exit code only.
  - `-v` and `-q` are mutually exclusive.

## Out of scope (later, maybe)

- CVF / ECVA / NeurIPS / OpenReview sources.
- Parallel/multi-connection downloads (aria2-style).
- Local index/JSON of all downloaded papers.
- Resumable downloads.
- arxiv search/listing.

## Per-paper output layout

```txt
$ARXIV_DOWNLOAD_PATH/   # default: $HOME/Downloads/ArXiv_Papers
  _shared/              # cached cross-paper assets (CSS, JS, fonts) — see below
    arxiv.org/static/browse/0.3.4/css/ar5iv.0.7.9.min.css
    cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css
    ...
  YYYY/MM/DD/<primary_category>/<arxiv-id>-<slug>/
    <arxiv-id>.pdf
    <arxiv-id>-abstract.html
    metadata.md
    metadata.yaml
    metadata.json
    metadata.bib
    html/
      <arxiv-id>.html        # path-rewritten: relative `x1.png` stays sibling; `/static/...` and CDN → ../../../../../../_shared/...
      x1.png, x2.png, ...    # paper-specific relative images, flat siblings
    src/
      *.tex, *.bbl, etc.     # extracted from /src/<id> tarball
```

Concrete example (ResNet, primary category cs.CV, submitted 2015-12-10):

```txt
2015/12/10/cs.CV/1512.03385-deep-residual-learning-for-image-recognition/
  1512.03385.pdf
  1512.03385-abstract.html
  metadata.md
  metadata.yaml
  metadata.json
  metadata.bib
  html/
    1512.03385.html
    x1.png ... x7.png
  src/
    main.tex, refs.bbl, ...
```

### Path components

- `YYYY/MM/DD` — from arxiv metadata `published` field (original submission date).
- `<primary_category>` — from arxiv metadata `primary_category.id` (e.g. `cs.CV`, `math.NT`).
- `<arxiv-id>` — for legacy IDs containing `/`, replace `/` with `-` (e.g. `cs/0002001` → `cs-0002001`).
- `<slug>` — derived from paper title via [`stringex`](https://github.com/rsl/stringex):
  - `title.to_url` (transliterates Greek/math/Unicode → ASCII, lowercases, hyphenates, strips punctuation)
  - then truncate to 80 chars at the last word boundary (split on `-`, drop trailing partial word)

Plaintext + structured sidecar files; multiple file types for redundancy.

### `metadata.md` shape

YAML frontmatter is the machine-readable form; the Markdown body is the human-readable form. **No deduping** — abstract and structured fields appear in both.

- Frontmatter fields: `arxiv_id`, `arxiv_url`, `pdf_url`, `title`, `authors[]`, `published`, `updated`, `primary_category{id,name,group}`, `categories[]{id,name,group}`, `comment`, `doi`, `journal_ref`, `bibtex_key`, `abstract` (literal block).
- Body: `# <title>` heading, then unordered list of authors (sub-list), published date, primary category (with human-readable name + group), arxiv ID link, PDF link. Then `## Abstract` heading and abstract text.
- Categories carry both id (`cs.CV`) and human name (`Computer Vision and Pattern Recognition`) + group (`Computer Science`). Lookup table embedded in the gem at `lib/arxiv/downloader/categories.yaml` (static arxiv taxonomy).

## Module layout

```txt
lib/arxiv/downloader.rb                # entry require
lib/arxiv/downloader/version.rb        # VERSION
lib/arxiv/downloader/identifier.rb     # parse string -> Identifier (pure)
lib/arxiv/downloader/client.rb         # HTTP wrapper (http.rb), rate-limited
lib/arxiv/downloader/metadata.rb       # value object: title, abstract, authors, etc.
lib/arxiv/downloader/feed_parser.rb    # Atom feed -> Metadata (feedjira)
lib/arxiv/downloader/categories.rb     # arxiv taxonomy lookup (id -> name, group)
lib/arxiv/downloader/categories.yaml   # static taxonomy data
lib/arxiv/downloader/slug.rb           # title -> filesystem-safe slug via stringex (pure)
lib/arxiv/downloader/path.rb           # metadata -> YYYY/MM/DD/cat/id-slug (pure)
lib/arxiv/downloader/bibtex.rb         # synthesize + fetch BibTeX
lib/arxiv/downloader/pdf.rb            # streaming PDF download
lib/arxiv/downloader/abstract_page.rb  # /abs/<id> download
lib/arxiv/downloader/html_archive.rb   # /html/<id> + assets + path rewrite
lib/arxiv/downloader/source_archive.rb # /src/<id> tarball + extract
lib/arxiv/downloader/assets_cache.rb   # shared asset cache under _shared/
lib/arxiv/downloader/paper.rb          # identifier + metadata + paths
lib/arxiv/downloader/archive.rb        # orchestrates all of the above per paper
lib/arxiv/downloader/cli.rb            # OptionParser + orchestration
exe/arxiv-dl                           # require + Cli.new(ARGV).run
```

Naming: instance-oriented (`Identifier.new(string).id`, not `Identifier.parse(string)`); proper-case initialisms (`HTTP`, `PDF`, `JSON`, `XML`); no abbreviations.

## Dependencies

Runtime:

- `http` — HTTP requests.
- `feedjira` — Atom XML parsing (with a custom `Arxiv::Downloader::AtomEntry` subclass to capture `arxiv:` and `opensearch:` namespace fields).
- `stringex` — title slugging (`String#to_url` for Unicode-to-ASCII transliteration).

Dev:

- `rspec`, `rubocop`, `rubocop-performance`, `rubocop-rake`, `rubocop-rspec`, `rake`, `irb`.

Stdlib only for: `optparse` (CLI), `fileutils`, `pathname`, `yaml`, `json`.

## arxiv API notes

- Endpoint: `https://export.arxiv.org/api/query?id_list=<id>` returns Atom XML.
- BibTeX (undocumented): `https://arxiv.org/bibtex/<id>` returns a `.bib` string.
- PDF: `https://arxiv.org/pdf/<id>.pdf` (or `<id>v<n>.pdf` for a specific version).
- Abstract page: `https://arxiv.org/abs/<id>` returns HTML (`Content-Type: text/html`).
- HTML version: `https://arxiv.org/html/<id>` returns HTML; references CSS/JS at `https://arxiv.org/static/browse/...` and CDNs (Bootstrap, html2canvas), plus relative paper-specific images (`x1.png`, etc.).
- Source: `https://arxiv.org/src/<id>` returns `application/gzip` (`Content-Disposition: attachment; filename="arXiv-<id>v<n>.tar.gz"`). Always-redirect note: arxiv 301-redirects from http → https; client must follow.
- No auth / API key required.
- Etiquette: ~1 request per 3 seconds; descriptive `User-Agent` header.
- `User-Agent`: `arxiv-dl/<VERSION> (+https://github.com/xoengineering/arxiv-dl)` — version pulled from `Arxiv::Downloader::VERSION`.

## TDD milestones

Each milestone is its own commit; each commit is green (`script/test` passes).

1. ✅ Skeleton + script/ + rubocop config — committed `9f64351`.
2. ✅ Rewrite scripts to Ruby pattern — committed `30b1837`.
3. ✅ **Identifier parsing** — `Identifier.new(input).id` and `.version` for every supported input form. Pure, no I/O. Table-driven specs. Final commit `c4989b5`.
4. ✅ **Slug** — `Slug.new(title).to_s`: `title.to_url` via `stringex`, then word-boundary truncation to 80 chars. Strips TeX math (`$...$`) and commands (`\emph`, `\alpha`) first. Pure. Final commit `fcd28d5`.
5. ✅ **Categories taxonomy** — `Categories.new.lookup('cs.CV')` returns `{id, name, group}`. Pure (reads embedded yaml). 155 categories across 8 groups extracted from arxiv's category_taxonomy page via `tmp/build_categories.rb`.
6. ✅ **HTTP client** — `Client.new.get(url)` wrapper around http.rb with proper `User-Agent` and rate-limit gate (sleeps between requests). WebMock-backed specs against fixture URLs.
7. ✅ **Atom feed → Metadata** — `FeedParser.new(xml).metadata` returns `Metadata` value object with title, authors, abstract, dates, arxiv_id/url/pdf_url, primary_category{id,name,group}, categories[], comment, doi, journal_ref. Custom `AtomEntry` subclass captures `arxiv:` namespace. Tested against `spec/fixtures/http/atom-{2508.16190,1207.7214}.xml`.
8. ✅ **Path** — `Path.new(metadata).to_s` → `YYYY/MM/DD/<cat>/<id>-<slug>` from metadata. Replaces `/` in legacy IDs with `-`. Pure.
9. ✅ **PDF download** — `PDF.new(identifier, client:).download to: path`. WebMock-backed spec with 4KB binary fixture.
10. ✅ **BibTeX** — `Bibtex.new(metadata, client:)`. `#synthesize` builds @misc entry from Metadata; `#fetch` hits `https://arxiv.org/bibtex/<id>`; `#to_s` prefers fetched, falls back to synthesized; works without a client too.
11. ✅ **Abstract page** — `AbstractPage.new(identifier, client:).download to: path`. Single HTML file.
12. **Source archive** — `SourceArchive.new(identifier, client:).download to: dir`: fetch tarball, extract via stdlib `tar` (or `rubygems/package`), drop tarball.
13. **Assets cache** — `AssetsCache.new(root:).fetch(url)` returns local path under `_shared/<host>/<path>`; downloads only if missing.
14. **HTML archive** — `HTMLArchive.new(identifier, client:, assets_cache:).download to: dir`: fetch HTML, parse asset URLs, fetch relative-path images (sibling), route same-host + CDN to assets cache, rewrite HTML paths.
15. **Sidecar writers** — `Metadata::Markdown.new(metadata).write`, `Metadata::YAML.new(metadata).write`, `Metadata::JSON.new(metadata).write`, `Metadata::Bibtex.new(metadata).write` produce the four sidecar files.
16. **Archive orchestrator** — `Archive.new(identifier, root:).run` ties everything together: fetch metadata → compute path → download all artifacts → write sidecars.
17. **CLI** — `Cli.new(argv).run` wires Archive. Flags: `-p/--path <path>`, `--rate-limit <seconds>`, `-v/--verbose`, `-q/--quiet`, `--version`, `-h/--help`. ENV fallbacks: `ARXIV_DOWNLOAD_PATH`, `ARXIV_RATE_LIMIT`. `-v` and `-q` mutually exclusive.
18. **README** — usage examples, install, env vars, output layout.
19. **CHANGELOG** — finalize the `[Unreleased]` section into `[0.1.0]` at release time. Until then, accumulate user-facing bullets in `[Unreleased]` only as features actually land (skip per-commit churn).

## Reference

- Vendored prior art (gitignored): `vendor/arxiv-dl-py/` — Python tool by Mark Hershey. Use to crib edge-case URL forms and metadata field shapes; **not** a structural template.
