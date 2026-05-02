RSpec.describe Arxiv::Downloader::Client do
  describe '#user_agent' do
    subject(:user_agent) { described_class.new.user_agent }

    it 'identifies the gem with version and source URL' do
      expect(user_agent).to eq "arxiv-dl/#{Arxiv::Downloader::VERSION} (+https://github.com/xoengineering/arxiv-dl)"
    end
  end
end
