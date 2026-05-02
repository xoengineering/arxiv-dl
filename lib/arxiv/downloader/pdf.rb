module Arxiv
  module Downloader
    class PDF
      def initialize identifier, client:
        @identifier = identifier
        @client     = client
      end

      def download to:
        File.binwrite to, @client.get(url).to_s
      end

      private

      def url
        "https://arxiv.org/pdf/#{@identifier.id}.pdf"
      end
    end
  end
end
