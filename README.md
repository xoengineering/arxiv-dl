# arxiv-dl

Ruby gem to download papers and metadata from [arxiv.org](https://arxiv.org) for offline archives.

For each paper it produces a self-contained per-paper folder with:

- The PDF
- The single-page abstract HTML
- The full HTML version (with images and a deduplicated, cross-paper shared assets cache)
- The TeX/LaTeX source tarball, extracted
- Four sidecar metadata files: `metadata.md`, `metadata.yaml`, `metadata.json`, `metadata.bib`

## Installation

```sh
gem install arxiv-dl
```

Or in a `Gemfile`:

```ruby
gem 'arxiv-dl'
```

## CLI usage

```sh
arxiv-dl <ARXIV_ID_OR_URL> [<ARXIV_ID_OR_URL>...]
```

Accepted input forms:

- Bare ID: `1512.03385`
- Prefixed ID: `arXiv:1512.03385`
- Legacy ID: `cs/0002001`, `alg-geom/9708001`
- Versioned ID: `1512.03385v2`
- Abstract URL: `https://arxiv.org/abs/1512.03385`
- PDF URL: `https://arxiv.org/pdf/1512.03385.pdf`
- HTML URL: `https://arxiv.org/html/2506.15442`

### Flags

| Flag                       | Description                                              |
| -------------------------- | -------------------------------------------------------- |
| `-p PATH`, `--path PATH`   | Root download directory                                  |
| `--rate-limit SECONDS`     | Seconds between HTTP requests; `0` disables throttling   |
| `-v`, `--verbose`          | Print step lines and per-request URL/byte logs to stdout |
| `-q`, `--quiet`            | Print nothing; success/failure conveyed via exit code    |
| `--version`                | Print the gem version and exit                           |
| `-h`, `--help`             | Print help and exit                                      |

`-v` and `-q` are mutually exclusive.

### Environment variables

| Variable               | Effect                                                                          |
| ---------------------- | ------------------------------------------------------------------------------- |
| `ARXIV_DOWNLOAD_PATH`  | Root download directory (default: `$HOME/Downloads/ArXiv_Papers`)               |
| `ARXIV_RATE_LIMIT`     | Seconds between HTTP requests (default: `3`, per arxiv etiquette; `0` disables) |

Precedence: CLI flag > ENV var > default.

### Examples

Download a single paper to the default location:

```sh
arxiv-dl 1512.03385
```

Download to a custom directory:

```sh
arxiv-dl --path ~/Archives/arxiv 1512.03385
```

Download multiple papers, verbose:

```sh
arxiv-dl -v 1512.03385 2508.16190 cs/0002001
```

Disable rate limiting (when running against a local mirror, etc):

```sh
arxiv-dl --rate-limit 0 1512.03385
```

## Output layout

```txt
$ARXIV_DOWNLOAD_PATH/                   # default: $HOME/Downloads/ArXiv_Papers
  _shared/                              # cross-paper deduplicated static assets
    arxiv.org/static/...
    cdn.jsdelivr.net/...
  YYYY/MM/DD/<primary_category>/<arxiv-id>-<slug>/
    <arxiv-id>.pdf
    <arxiv-id>-abstract.html
    metadata.md                         # YAML frontmatter + Markdown body
    metadata.yaml
    metadata.json
    metadata.bib                        # upstream BibTeX, falls back to synthesized
    html/
      <arxiv-id>.html                   # path-rewritten to local assets
      x1.png, x2.png, ...               # paper-specific images
    src/
      *.tex, *.bbl, ...                 # extracted from /src/<id> tarball
```

`YYYY/MM/DD` is the original submission date. `<primary_category>` is from the paper's metadata (`cs.CV`, `math.NT`, etc). `<slug>` is derived from the paper title (Unicode → ASCII, hyphenated, truncated to 80 chars at a word boundary).

For legacy IDs containing `/` (e.g. `cs/0002001`), the slash is replaced with `-` in the directory name (`cs-0002001-...`).

## Library usage

```ruby
require 'arxiv/downloader'

identifier = Arxiv::Downloader::Identifier.new '1512.03385'
client     = Arxiv::Downloader::Client.new                # 3-second rate limit by default
path       = Arxiv::Downloader::Archive.new(identifier, root: '/tmp/papers', client: client).run
# => "/tmp/papers/2015/12/10/cs.CV/1512.03385-deep-residual-learning-for-image-recognition"
```

## Development

```sh
script/setup    # install dependencies
script/test     # run specs and rubocop
script/console  # interactive prompt
```

## License

MIT — see [LICENSE.md](LICENSE.md).

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
