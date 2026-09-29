## [0.3.1]

- Built on [dl-core](https://github.com/xoengineering/dl-core) 0.1: the HTTP client, errors, `Author`, `Slug`, sidecar writers, and CLI now come from it instead of copies. No change in behavior or output. `Arxiv::Downloader::Client`, `HTTPError`, `Author`, `Slug`, and `Metadata::YAML`/`JSON` still work; they are now `dl-core`'s classes. `Arxiv::Downloader::Error` now subclasses `DL::Core::Error`.
- Direct dependencies on `http`, `stringex`, and `ostruct` replaced by `dl-core`.

## [0.3.0]

Less folder nesting for the common case: most papers only ever have one version.

### Breaking

- Single-version papers are archived flat again: a paper whose only archived version is v1 keeps its files directly in the paper folder, without a `v1/` level. `v<N>/` folders are used only when a paper has more than one version. Archiving a second version of a flat paper moves the existing files into `v<N>/` first, rewriting `html/` links into `_shared/` for the new depth. A paper whose latest version is v2 or later starts out in `v<N>/` folders. Existing 0.2.0 archives keep their `v1/` folders.

## [0.2.0]

Versioned archives, author affiliations, and a round of robustness fixes. Two breaking changes to the output layout and metadata; see below.

### Breaking

- Versioned layout. Each archived version goes in its own `v<N>/` folder under the paper folder, with versioned filenames (`2508.16190v1.pdf`, `2508.16190v1-abstract.html`, `html/2508.16190v1.html`). A versioned ID (`2508.16190v1`) now archives that version instead of silently downloading the latest; an unversioned ID archives the latest.
- Author affiliations. `Metadata#authors` is now a list of `Arxiv::Downloader::Author` (`name`, `affiliations`) instead of name strings. `metadata.yaml`, `metadata.json`, and the `metadata.md` frontmatter write `authors` as a list of `{ name, affiliations }`.
- Minimum Ruby version is now 4.0.7.

### Added

- Author affiliations (`arxiv:affiliation`) are parsed from the Atom feed. The `metadata.md` body lists them after each author name: `- Jon S. Lawrence (Australian Astronomical Observatory; Macquarie University)`. BibTeX output is unchanged: names only.
- `Metadata#version` records which paper version was archived; the sidecars include it as `version`.
- Re-running skips versions already archived. Each version downloads into `v<N>.partial/` and is renamed to `v<N>/` only when complete, so a failed run never leaves a folder that looks finished.
- CLI: `-i FILE` / `--input FILE` reads targets one per line (`-` for stdin; blank lines and `#` comments skipped), combined with any argument targets.
- 429 and 503 responses are retried up to 3 times, waiting for `Retry-After` seconds when arxiv sends it, otherwise backing off 10s, 20s, 40s. Retries are logged with `-v`.
- HTTP requests time out (10s connect, 10s write, 60s per read) instead of hanging forever on a stalled connection.

### Fixed

- `Client#get` raises `Arxiv::Downloader::HTTPError` (with `status` and `url`) on non-success responses, instead of returning error bodies that were written to disk as PDFs/HTML or crashed the Atom parser.
- CLI: a failing target is reported on stderr as `<target>: <message>` and the remaining targets still download. Exit status is `1` if any target failed. Previously the first failure aborted the batch with a stack trace.
- An ID arxiv has no paper for raises `Arxiv::Downloader::PaperNotFound` instead of `NoMethodError`.
- Papers with no HTML version (404) skip the `html/` archive instead of saving arxiv's 404 page. A missing HTML asset (404) leaves its reference untouched instead of failing the paper.
- Source downloads handle more than gzipped tarballs: a single gzipped file is written under its original name, a PDF-only submission's source is skipped (the PDF is already archived), and unrecognized formats are kept as raw bytes in `src/<id>`.
- Legacy IDs (`cs/0002001`) no longer fail to write files: the `/` is replaced with `-` in file names, as it already was in the paper folder name.

### Security

- Source tarball entries that resolve outside `src/` (`../` or absolute paths) are skipped instead of written.

## [0.1.1]

Bug fix: the HTML archive step crashed with `NoMethodError` on papers whose HTML embeds `data:` URI images (e.g. arxiv's feedback-overlay mascot), and mis-fetched root-relative `/static/...` asset references from a wrong page-relative URL.

- Asset references are now routed by type: page-relative refs download as siblings, absolute `http(s)` refs cache under `_shared/`, root-relative refs are absolutized against `arxiv.org` and cache under `_shared/`, and unfetchable refs (`data:`, `javascript:`, `mailto:`, malformed URIs) are left in the HTML untouched.

## [0.1.0]

First release. Per-paper offline archive of arxiv.org papers, with PDF, abstract HTML, full HTML version (with relative-path images and a deduplicated cross-paper shared assets cache), TeX source, and four metadata sidecar files.

### CLI

- `arxiv-dl <ARXIV_ID_OR_URL>...` accepts bare IDs, prefixed IDs, legacy IDs (`cs/0002001`), versioned IDs (`2508.16190v1`), and `/abs`, `/pdf`, `/html` URLs.
- Flags: `-p/--path PATH`, `--rate-limit SECONDS`, `-v/--verbose`, `-q/--quiet`, `--version`, `-h/--help`. `-v` and `-q` are mutually exclusive.
- ENV fallbacks: `ARXIV_DOWNLOAD_PATH`, `ARXIV_RATE_LIMIT`. Precedence: CLI flag > ENV > default.
- Default download path: `$HOME/Downloads/ArXiv_Papers`. Default rate limit: 3 seconds (arxiv etiquette).
- Verbose mode prints `==> Downloading <id>` step lines and `==> GET <url> (<bytes> bytes)` per HTTP request.

### Per-paper output layout

```txt
$ARXIV_DOWNLOAD_PATH/
  _shared/<host>/<path>           # deduplicated cross-paper static assets (CSS, JS, fonts)
  YYYY/MM/DD/<primary_category>/<arxiv-id>-<slug>/
    <arxiv-id>.pdf
    <arxiv-id>-abstract.html
    metadata.{md,yaml,json,bib}
    html/<arxiv-id>.html + x1.png, x2.png, ...
    src/*.tex, *.bbl, ...
```

### Library API

- `Arxiv::Downloader::Identifier.new(input).id` / `.version` parses every supported input form.
- `Arxiv::Downloader::Client.new(rate_limit:, log:).get(url)` is the rate-limited HTTP wrapper.
- `Arxiv::Downloader::FeedParser.new(xml).metadata` parses the arxiv Atom feed into a `Metadata` value object.
- `Arxiv::Downloader::Bibtex.new(metadata, client:)` produces synthesized or fetched BibTeX.
- `Arxiv::Downloader::PDF`, `AbstractPage`, `HTMLArchive`, `SourceArchive`, `AssetsCache` download individual artifacts.
- `Arxiv::Downloader::Metadata::{Markdown,YAML,JSON,Bibtex}.new(metadata).write(to: dir)` produce the four sidecar files.
- `Arxiv::Downloader::Archive.new(identifier, root:, client:).run` orchestrates the full per-paper pipeline and returns the paper directory path.

### Dependencies

Runtime: `feedjira`, `http`, `nokogiri`, `ostruct`, `stringex`. Stdlib only for the rest (`optparse`, `fileutils`, `pathname`, `yaml`, `json`, `rubygems/package`, `zlib`).
