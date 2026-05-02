require 'stringex'

module Arxiv
  module Downloader
    class Slug
      MAX_LENGTH = 80

      def initialize title
        @title = title
      end

      def to_s
        truncate @title.to_url
      end

      private

      def truncate slug
        return slug if slug.length <= MAX_LENGTH

        words = slug.split '-'
        result = +''
        words.each do |word|
          break if result.length + 1 + word.length > MAX_LENGTH

          result << '-' unless result.empty?
          result << word
        end
        result
      end
    end
  end
end
