require 'fileutils'
require 'json'

module Arxiv
  module Downloader
    class Metadata
      class JSON
        FILENAME = 'metadata.json'.freeze

        def initialize metadata
          @metadata = metadata
        end

        def write to:
          FileUtils.mkdir_p to
          File.write File.join(to, FILENAME), "#{::JSON.pretty_generate(serialize(@metadata.to_h))}\n"
        end

        private

        def serialize object
          case object
          when Hash       then object.to_h { |key, value| [key.to_s, serialize(value)] }
          when Array      then object.map { |item| serialize item }
          when Date, Time then object.iso8601
          else object
          end
        end
      end
    end
  end
end
