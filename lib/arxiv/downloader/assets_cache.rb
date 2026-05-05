require 'fileutils'
require 'uri'

module Arxiv
  module Downloader
    class AssetsCache
      SHARED_DIR = '_shared'.freeze

      def initialize root:, client:
        @root   = root
        @client = client
      end

      def fetch url
        path = local_path_for url
        return path if File.exist? path

        FileUtils.mkdir_p File.dirname(path)
        File.binwrite path, @client.get(url).to_s

        path
      end

      private

      def local_path_for url
        uri = URI.parse url
        File.join @root, SHARED_DIR, uri.host, uri.path.delete_prefix('/')
      end
    end
  end
end
