require 'stringex'

module Arxiv
  module Downloader
    class Slug
      def initialize title
        @title = title
      end

      def to_s
        @title.to_url
      end
    end
  end
end
