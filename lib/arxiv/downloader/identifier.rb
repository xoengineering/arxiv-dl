module Arxiv
  module Downloader
    class Identifier
      class Invalid < Error; end

      MODERN_ID  = /\A(\d{4}\.\d{4,5})(?:v(\d+))?\z/
      LEGACY_ID  = %r{\A([a-z][a-z-]+/\d{7})(?:v(\d+))?\z}
      PREFIX     = /\AarXiv:/i
      URL_PREFIX = %r{\Ahttps?://arxiv\.org/(?:abs|pdf|html)/}
      PDF_SUFFIX = /\.pdf\z/

      attr_reader :id, :version

      def initialize input
        normalized = normalize input
        match      = MODERN_ID.match(normalized) || LEGACY_ID.match(normalized)

        raise Invalid, "not a recognizable arxiv identifier: #{input.inspect}" unless match

        @id      = match[1]
        @version = match[2]&.to_i
      end

      private

      def normalize input
        input.sub(URL_PREFIX, '')
             .sub(PDF_SUFFIX, '')
             .sub(PREFIX, '')
      end
    end
  end
end
