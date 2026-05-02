require 'feedjira'

module Arxiv
  module Downloader
    class FeedParser
      def initialize xml
        @feed = Feedjira.parse xml
      end

      def metadata
        entry = @feed.entries.first
        Metadata.new(title: entry.title)
      end
    end
  end
end
