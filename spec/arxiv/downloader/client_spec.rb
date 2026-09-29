# Rate limiting, retries, and timeouts are specified in dl-core.
RSpec.describe Arxiv::Downloader::Client do
  it 'is a DL::Core::Client' do
    expect(described_class.new).to be_a DL::Core::Client
  end

  it 'identifies arxiv-dl with version and source URL' do
    expect(described_class.new.user_agent)
      .to eq "arxiv-dl/#{Arxiv::Downloader::VERSION} (+https://github.com/xoengineering/arxiv-dl)"
  end

  it 'defaults to a 3-second rate limit (arxiv etiquette)' do
    expect(described_class.new.rate_limit).to eq 3
  end

  it 'passes the rate limit and log through' do
    log = StringIO.new
    url = 'https://export.arxiv.org/api/query?id_list=2508.16190'
    stub_request(:get, url).to_return(status: 200, body: File.read('spec/fixtures/http/atom-2508.16190.xml'))

    client = described_class.new(rate_limit: 0, log: log)
    client.get url

    expect(client.rate_limit).to eq 0
    expect(log.string).to include "==> GET #{url}"
  end
end
