require 'http'

module Arxiv
  module Downloader
    class Client
      SOURCE_URL         = 'https://github.com/xoengineering/arxiv-dl'.freeze
      DEFAULT_RATE_LIMIT = 3

      attr_reader :rate_limit

      def initialize rate_limit: DEFAULT_RATE_LIMIT
        @rate_limit = rate_limit
      end

      def user_agent
        "arxiv-dl/#{VERSION} (+#{SOURCE_URL})"
      end

      def get url
        HTTP.headers('User-Agent' => user_agent).follow.get(url)
      end
    end
  end
end
