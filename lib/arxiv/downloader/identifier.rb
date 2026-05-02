module Arxiv
  module Downloader
    class Identifier
      MODERN_ID  = /\A(\d{4}\.\d{4,5})(?:v(\d+))?\z/
      PREFIX     = /\AarXiv:/i
      URL_PREFIX = %r{\Ahttps?://arxiv\.org/(?:abs|pdf|html)/}
      PDF_SUFFIX = /\.pdf\z/

      attr_reader :id, :version

      def initialize input
        match = MODERN_ID.match normalize(input)

        @id      = match[1]
        @version = match[2]&.to_i
      end

      private

      def normalize input
        input
          .sub(URL_PREFIX, '')
          .sub(PDF_SUFFIX, '')
          .sub(PREFIX, '')
      end
    end
  end
end
