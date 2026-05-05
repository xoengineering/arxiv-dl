require 'fileutils'

module Arxiv
  module Downloader
    class Metadata
      class Bibtex
        FILENAME = 'metadata.bib'.freeze

        def initialize metadata, client: nil
          @metadata = metadata
          @client   = client
        end

        def write to:
          FileUtils.mkdir_p to
          File.write File.join(to, FILENAME), Downloader::Bibtex.new(@metadata, client: @client).to_s
        end
      end
    end
  end
end
