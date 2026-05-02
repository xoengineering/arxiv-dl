module Arxiv
  module Downloader
    class Identifier
      MODERN_ID = /\A(\d{4}\.\d{4,5})(?:v(\d+))?\z/
      PREFIX    = /\AarXiv:/i

      attr_reader :id, :version

      def initialize input
        match = MODERN_ID.match input.sub(PREFIX, '')

        @id      = match[1]
        @version = match[2]&.to_i
      end
    end
  end
end
