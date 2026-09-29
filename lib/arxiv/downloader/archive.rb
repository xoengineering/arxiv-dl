require 'fileutils'

module Arxiv
  module Downloader
    class Archive
      def initialize identifier, root:, client: Client.new
        @identifier = identifier
        @root       = root
        @client     = client
      end

      # Downloads into <destination>.partial/ and
      # renames it into place only once everything succeeded.
      # An archived version is always complete and is skipped.
      # PaperFolder decides flat (single version) vs v<N>/ (several versions).
      def run
        return paper_folder.location_of(metadata.version) if paper_folder.archived? metadata.version

        paper_folder.unflatten!
        FileUtils.rm_rf staging_dir
        FileUtils.mkdir_p staging_dir

        download_pdf
        download_abstract
        download_html_archive
        download_source_archive
        write_sidecars

        File.rename staging_dir, destination
        destination
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

      def paper_folder
        @paper_folder ||= PaperFolder.new File.join(@root, Path.new(metadata).to_s)
      end

      # evaluated after unflatten!, which can turn a flat folder into v<N>/ folders
      def destination
        @destination ||= paper_folder.destination_for metadata.version
      end

      # a sibling of destination, so relative ../_shared/ refs survive the rename
      def staging_dir
        "#{destination}.partial"
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
