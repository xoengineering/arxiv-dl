module Arxiv
  module Downloader
    # DL::Core::Client with arxiv-dl's User-Agent filled in
    class Client < DL::Core::Client
      SOURCE_URL = 'https://github.com/xoengineering/arxiv-dl'.freeze
      USER_AGENT = "arxiv-dl/#{VERSION} (+#{SOURCE_URL})".freeze

      def initialize log: nil, rate_limit: DEFAULT_RATE_LIMIT
        super(user_agent: USER_AGENT, log:, rate_limit:)
      end
    end
  end
end
