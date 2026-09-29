module Arxiv
  module Downloader
    class PaperNotFound < Error
      def initialize message = 'arxiv API returned no paper'
        super
      end
    end
  end
end
