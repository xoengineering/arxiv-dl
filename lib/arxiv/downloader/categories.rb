require 'yaml'

module Arxiv
  module Downloader
    class Categories
      DATA_PATH = File.expand_path('categories.yaml', __dir__).freeze

      def initialize
        @data = YAML.load_file(DATA_PATH)
      end

      def lookup id
        entry = @data[id]
        return nil if entry.nil?

        { id: id, name: entry['name'], group: entry['group'] }
      end
    end
  end
end
