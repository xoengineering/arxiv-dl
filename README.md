# arxiv-dl

Download papers and metadata from [arxiv.org](https://arxiv.org) for offline archives.

Part of [Archivistism](https://github.com/veganstraightedge/archivistism) — tools for building offline archives of important cultural works.

## Installation

```bash
gem install arxiv-dl
```

Or in a `Gemfile`:

```ruby
gem "arxiv-dl"
```

## Usage

CLI:

```bash
arxiv-dl <arxiv-id-or-url>
```

Library:

```ruby
require "arxiv/downloader"
```

## Development

```bash
script/bootstrap   # install dependencies
script/test        # run specs and linter
script/console     # interactive prompt
```

## License

MIT — see [LICENSE.txt](LICENSE.txt).

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
