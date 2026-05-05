require 'fileutils'
require 'yaml'

module Arxiv
  module Downloader
    class Metadata
      class YAML
        FILENAME = 'metadata.yaml'.freeze

        def initialize metadata
          @metadata = metadata
        end

        def write to:
          FileUtils.mkdir_p to
          File.write File.join(to, FILENAME), ::YAML.dump(stringify(@metadata.to_h))
        end

        private

        def stringify object
          case object
          when Hash  then object.to_h { |key, value| [key.to_s, stringify(value)] }
          when Array then object.map { |item| stringify item }
          else object
          end
        end
      end
    end
  end
end
