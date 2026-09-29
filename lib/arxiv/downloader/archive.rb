require 'fileutils'

module Arxiv
  module Downloader
    class Archive
      def initialize identifier, root:, client: Client.new
        @identifier = identifier
        @root       = root
        @client     = client
      end

      # Downloads into v<N>.partial/ and renames it to v<N>/ only once everything
      # succeeded, so an existing v<N>/ is always complete and is skipped.
      def run
        return paper_dir if Dir.exist? paper_dir

        FileUtils.rm_rf staging_dir
        FileUtils.mkdir_p staging_dir

        download_pdf
        download_abstract
        download_html_archive
        download_source_archive
        write_sidecars

        File.rename staging_dir, paper_dir
        paper_dir
      end

      private

      def metadata
        @metadata ||= FeedParser.new(@client.get(atom_url).to_s).metadata
      end

      # the requested version, or the latest when none was requested
      def atom_url
        "https://export.arxiv.org/api/query?id_list=#{@identifier}"
      end

      # the version the API actually returned, so every download matches the metadata
      def archived
        @archived ||= Identifier.new "#{metadata.arxiv_id}v#{metadata.version}"
      end

      def paper_dir
        @paper_dir ||= File.join @root, Path.new(metadata).to_s, "v#{metadata.version}"
      end

      # a sibling of paper_dir, so relative ../_shared/ refs survive the rename
      def staging_dir
        "#{paper_dir}.partial"
      end

      def download_pdf
        PDF.new(archived, client: @client).download to: File.join(staging_dir, "#{archived.file_stem}.pdf")
      end

      def download_abstract
        AbstractPage.new(archived, client: @client)
                    .download to: File.join(staging_dir, "#{archived.file_stem}-abstract.html")
      end

      def download_html_archive
        HTMLArchive.new(archived, client: @client, assets_cache: assets_cache)
                   .download to: File.join(staging_dir, 'html')
      end

      def download_source_archive
        SourceArchive.new(archived, client: @client).download to: File.join(staging_dir, 'src')
      end

      def assets_cache
        @assets_cache ||= AssetsCache.new root: @root, client: @client
      end

      def write_sidecars
        Metadata::Markdown.new(metadata).write to: staging_dir
        Metadata::YAML.new(metadata).write     to: staging_dir
        Metadata::JSON.new(metadata).write     to: staging_dir
        Metadata::Bibtex.new(metadata, client: @client).write to: staging_dir
      end
    end
  end
end
