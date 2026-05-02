module Arxiv
  module Downloader
    class Path
      def initialize metadata
        @metadata = metadata
      end

      def to_s
        [date_dir, category, "#{filesystem_safe_id}-#{slug}"].join '/'
      end

      private

      def date_dir
        @metadata.published.strftime '%Y/%m/%d'
      end

      def category
        @metadata.primary_category[:id]
      end

      def filesystem_safe_id
        @metadata.arxiv_id.tr '/', '-'
      end

      def slug
        Slug.new(@metadata.title).to_s
      end
    end
  end
end
