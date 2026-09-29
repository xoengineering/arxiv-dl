require 'http'

module Arxiv
  module Downloader
    class Client
      SOURCE_URL         = 'https://github.com/xoengineering/arxiv-dl'.freeze
      DEFAULT_RATE_LIMIT = 3
      TIMEOUTS           = { connect: 10, read: 60, write: 10 }.freeze # seconds, per operation

      attr_reader :rate_limit

      def initialize rate_limit: DEFAULT_RATE_LIMIT, log: nil
        @rate_limit = rate_limit
        @log        = log
      end

      def user_agent
        "arxiv-dl/#{VERSION} (+#{SOURCE_URL})"
      end

      def get url
        throttle
        response = HTTP.timeout(TIMEOUTS).headers('User-Agent' => user_agent).follow.get(url)
        @last_request_at = Time.now
        log_request url, response
        raise_unless_success url, response
        response
      end

      private

      def raise_unless_success url, response
        return if response.status.success?

        raise HTTPError.new(status: response.status.code, url: url, reason: response.status.reason)
      end

      def log_request url, response
        return if @log.nil?

        @log.puts "==> GET #{url} (#{response.body.to_s.bytesize} bytes)"
      end

      def throttle
        return if @rate_limit.zero?
        return if @last_request_at.nil?

        elapsed = Time.now - @last_request_at
        return if elapsed >= @rate_limit

        sleep(@rate_limit - elapsed)
      end
    end
  end
end
