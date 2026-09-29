require_relative 'downloader/abstract_page'
require_relative 'downloader/archive'
require_relative 'downloader/assets_cache'
require_relative 'downloader/author'
require_relative 'downloader/bibtex'
require_relative 'downloader/categories'
require_relative 'downloader/cli'
require_relative 'downloader/client'
require_relative 'downloader/error'             # before http_error and identifier: they subclass Error
require_relative 'downloader/feed_parser'
require_relative 'downloader/html_archive'
require_relative 'downloader/http_error'        # after error
require_relative 'downloader/identifier'        # after error
require_relative 'downloader/metadata'          # before metadata/*: they reopen class Metadata
require_relative 'downloader/metadata/bibtex'   # after metadata
require_relative 'downloader/metadata/json'     # after metadata
require_relative 'downloader/metadata/markdown' # after metadata
require_relative 'downloader/metadata/yaml'     # after metadata
require_relative 'downloader/path'
require_relative 'downloader/pdf'
require_relative 'downloader/slug'
require_relative 'downloader/source_archive'
require_relative 'downloader/version'

module Arxiv
  module Downloader
  end
end
