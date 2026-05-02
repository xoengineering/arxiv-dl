module Arxiv
  module Downloader
    class Identifier
      attr_reader :id

      def initialize input
        @id = input
      end
    end
  end
end
