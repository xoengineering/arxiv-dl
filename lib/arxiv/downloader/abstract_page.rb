module Arxiv
  module Downloader
    class AbstractPage
      def initialize identifier, client:
        @identifier = identifier
        @client     = client
      end

      def download to:
        File.write to, @client.get(url).to_s
      end

      private

      def url
        "https://arxiv.org/abs/#{@identifier.id}"
      end
    end
  end
end
