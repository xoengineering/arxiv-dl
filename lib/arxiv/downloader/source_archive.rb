require 'fileutils'
require 'rubygems/package'
require 'stringio'
require 'zlib'

module Arxiv
  module Downloader
    class SourceArchive
      GZIP_MAGIC = "\x1F\x8B".b.freeze
      PDF_MAGIC  = '%PDF'.b.freeze
      TAR_MAGIC  = 'ustar'.b.freeze

      def initialize identifier, client:
        @identifier = identifier
        @client     = client
      end

      def download to:
        body = @client.get(url).to_s.b

        # PDF-only submission: the PDF is already archived alongside src/
        return if body.start_with? PDF_MAGIC

        FileUtils.mkdir_p to
        return extract_gzip body, to if body.start_with? GZIP_MAGIC

        # unrecognized format: keep the raw bytes rather than lose them
        File.binwrite File.join(to, @identifier.id), body
      end

      private

      # arxiv serves either a gzipped tarball or a single gzipped file
      def extract_gzip body, to
        Zlib::GzipReader.wrap StringIO.new(body) do |gz|
          contents = gz.read
          next extract_tar contents, to if tar? contents

          filename = File.basename(gz.orig_name || @identifier.id)
          File.binwrite File.join(to, filename), contents
        end
      end

      def url
        "https://arxiv.org/src/#{@identifier.id}"
      end

      def tar? contents
        contents.byteslice(257, TAR_MAGIC.bytesize) == TAR_MAGIC
      end

      def extract_tar contents, to
        Gem::Package::TarReader.new StringIO.new(contents) do |tar|
          tar.each { |entry| extract entry, to }
        end
      end

      def extract entry, root
        path = File.expand_path entry.full_name, root
        return unless inside? path, root

        if entry.directory?
          FileUtils.mkdir_p path
        elsif entry.file?
          FileUtils.mkdir_p File.dirname(path)
          File.binwrite path, entry.read
        end
      end

      # guards against tar entries like ../escaped.txt or /etc/passwd
      def inside? path, root
        path.start_with? File.join(File.expand_path(root), '')
      end
    end
  end
end
