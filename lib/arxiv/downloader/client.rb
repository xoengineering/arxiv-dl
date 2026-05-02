module Arxiv
  module Downloader
    class Client
      SOURCE_URL = 'https://github.com/xoengineering/arxiv-dl'.freeze

      def user_agent
        "arxiv-dl/#{VERSION} (+#{SOURCE_URL})"
      end
    end
  end
end
