require 'fileutils'
require 'rubygems/package'
require 'stringio'
require 'zlib'

module Arxiv
  module Downloader
    class SourceArchive
      def initialize identifier, client:
        @identifier = identifier
        @client     = client
      end

      def download to:
        FileUtils.mkdir_p to

        body = @client.get(url).to_s
        Zlib::GzipReader.wrap StringIO.new(body) do |gz|
          Gem::Package::TarReader.new(gz) do |tar|
            tar.each { |entry| extract entry, to }
          end
        end
      end

      private

      def url
        "https://arxiv.org/src/#{@identifier.id}"
      end

      def extract entry, root
        path = File.join root, entry.full_name

        if entry.directory?
          FileUtils.mkdir_p path
        elsif entry.file?
          FileUtils.mkdir_p File.dirname(path)
          File.binwrite path, entry.read
        end
      end
    end
  end
end
