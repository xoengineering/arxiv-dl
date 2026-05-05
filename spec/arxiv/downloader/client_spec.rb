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

    context 'with rate-limiting enabled' do
      let(:client) { described_class.new(rate_limit: 3) }

      it 'does not sleep on the first request' do
        allow(client).to receive(:sleep)

        client.get url

        expect(client).not_to have_received(:sleep)
      end

      it 'sleeps before the second request to maintain the interval' do
        allow(client).to receive(:sleep)

        client.get url
        client.get url

        expect(client).to have_received(:sleep) do |seconds|
          expect(seconds).to be > 0
          expect(seconds).to be <= 3
        end
      end
    end

    context 'with rate-limiting disabled (rate_limit: 0)' do
      let(:client) { described_class.new(rate_limit: 0) }

      it 'never sleeps' do
        allow(client).to receive(:sleep)

        client.get url
        client.get url

        expect(client).not_to have_received(:sleep)
      end
    end

    context 'with a log sink' do
      it 'writes a step line per request with URL and byte count' do
        log = StringIO.new
        described_class.new(rate_limit: 0, log: log).get url

        expect(log.string).to include "==> GET #{url}"
        expect(log.string).to include "(#{body.bytesize} bytes)"
      end
    end
  end
end
