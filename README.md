# arxiv-dl

Ruby gem to download papers and metadata from [arxiv.org](https://arxiv.org) for offline archives.

## Installation

```sh
gem install arxiv-dl
```

Or in a `Gemfile`:

```ruby
gem 'arxiv-dl'
```

## Usage

CLI:

```sh
arxiv-dl <ARXIV_ID_OR_URL>
```

Library:

```ruby
require 'arxiv/downloader'
```

## Development

```sh
script/bootstrap # install dependencies
script/test      # run specs and linter
script/console   # interactive prompt
```

## License

MIT — see [LICENSE.md](LICENSE.md).

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
