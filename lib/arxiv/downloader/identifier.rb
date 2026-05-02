module Arxiv
  module Downloader
    class Identifier
      MODERN_ID = /\A(\d{4}\.\d{4,5})(?:v(\d+))?\z/

      attr_reader :id, :version

      def initialize input
        match = MODERN_ID.match input

        @id      = match[1]
        @version = match[2]&.to_i
      end
    end
  end
end
