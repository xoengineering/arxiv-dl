## [Unreleased]

- Initial gem skeleton
- Source archive download: fetch `/src/<id>` tarball and extract into a target directory
- Assets cache: deduplicate cross-paper static assets under `_shared/<host>/<path>`
- HTML archive: fetch `/html/<id>`, download relative images as siblings, route same-host and CDN assets through assets cache, rewrite paths
- Add nokogiri runtime dependency for HTML parsing
- Sidecar writers: `Metadata::Markdown`, `Metadata::YAML`, `Metadata::JSON`, `Metadata::Bibtex` produce `metadata.{md,yaml,json,bib}` in a target directory
