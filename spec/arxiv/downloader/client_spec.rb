RSpec.describe Arxiv::Downloader::Client do
  describe '#user_agent' do
    subject(:user_agent) { described_class.new.user_agent }

    it 'identifies the gem with version and source URL' do
      expect(user_agent).to eq "arxiv-dl/#{Arxiv::Downloader::VERSION} (+https://github.com/xoengineering/arxiv-dl)"
    end
  end

  describe '#rate_limit' do
    context 'with no argument' do
      it 'defaults to 3 seconds (arxiv etiquette)' do
        expect(described_class.new.rate_limit).to eq 3
      end
    end

    context 'with an explicit interval' do
      it 'returns the configured interval' do
        expect(described_class.new(rate_limit: 1).rate_limit).to eq 1
      end
    end

    context 'with zero (disabled)' do
      it 'returns 0' do
        expect(described_class.new(rate_limit: 0).rate_limit).to eq 0
      end
    end
  end

  describe '#get' do
    let(:client) { described_class.new(rate_limit: 0) }
    let(:url)    { 'https://export.arxiv.org/api/query?id_list=2508.16190' }
    let(:body)   { File.read 'spec/fixtures/http/atom-2508.16190.xml' }

    before { stub_request(:get, url).to_return(status: 200, body: body) }

    it 'returns the response body' do
      expect(client.get(url).to_s).to eq body
    end

    it 'sends the gem User-Agent header' do
      client.get url

      expect(WebMock).to have_requested(:get, url).with(headers: { 'User-Agent' => client.user_agent })
    end
  end
end
