module Arxiv
  module Downloader
    class CLI < DL::Core::CLI
      def program = 'arxiv-dl'

      def target_name = 'ARXIV_ID_OR_URL'

      # ARXIV_DOWNLOAD_PATH, ARXIV_RATE_LIMIT
      def env_prefix = 'ARXIV'

      def default_path = File.join(Dir.home, 'Downloads', 'ArXiv_Papers')

      def version = VERSION

      def user_agent = Client::USER_AGENT

      def client_for(rate_limit:, log:) = Client.new(rate_limit:, log:)

      def identifier_for(target) = Identifier.new(target)

      def archive_for(identifier, root:, client:) = Archive.new(identifier, root:, client:)
    end
  end
end
