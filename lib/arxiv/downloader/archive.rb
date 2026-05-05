require 'fileutils'

module Arxiv
  module Downloader
    class Archive
      def initialize identifier, root:, client: Client.new
        @identifier = identifier
        @root       = root
        @client     = client
      end

      def run
        FileUtils.mkdir_p paper_dir

        download_pdf
        download_abstract
        download_html_archive
        download_source_archive
        write_sidecars

        paper_dir
      end

      private

      def metadata
        @metadata ||= FeedParser.new(@client.get(atom_url).to_s).metadata
      end

      def atom_url
        "https://export.arxiv.org/api/query?id_list=#{@identifier.id}"
      end

      def paper_dir
        @paper_dir ||= File.join @root, Path.new(metadata).to_s
      end

      def download_pdf
        PDF.new(@identifier, client: @client).download to: File.join(paper_dir, "#{@identifier.id}.pdf")
      end

      def download_abstract
        AbstractPage.new(@identifier, client: @client)
                    .download to: File.join(paper_dir, "#{@identifier.id}-abstract.html")
      end

      def download_html_archive
        HTMLArchive.new(@identifier, client: @client, assets_cache: assets_cache)
                   .download to: File.join(paper_dir, 'html')
      end

      def download_source_archive
        SourceArchive.new(@identifier, client: @client).download to: File.join(paper_dir, 'src')
      end

      def assets_cache
        @assets_cache ||= AssetsCache.new root: @root, client: @client
      end

      def write_sidecars
        Metadata::Markdown.new(metadata).write to: paper_dir
        Metadata::YAML.new(metadata).write     to: paper_dir
        Metadata::JSON.new(metadata).write     to: paper_dir
        Metadata::Bibtex.new(metadata, client: @client).write to: paper_dir
      end
    end
  end
end
