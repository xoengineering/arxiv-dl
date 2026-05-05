## [0.1.0]

First release. Per-paper offline archive of arxiv.org papers, with PDF, abstract HTML, full HTML version (with relative-path images and a deduplicated cross-paper shared assets cache), TeX source, and four metadata sidecar files.

### CLI

- `arxiv-dl <ARXIV_ID_OR_URL>...` accepts bare IDs, prefixed IDs, legacy IDs (`cs/0002001`), versioned IDs (`1512.03385v2`), and `/abs`, `/pdf`, `/html` URLs.
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
