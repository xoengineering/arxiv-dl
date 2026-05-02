require 'tmpdir'

RSpec.describe Arxiv::Downloader::AbstractPage do
  let(:identifier) { Arxiv::Downloader::Identifier.new '2508.16190' }
  let(:client)     { Arxiv::Downloader::Client.new(rate_limit: 0) }
  let(:fixture)    { File.read 'spec/fixtures/http/abstract-2508.16190.html' }
  let(:url)        { 'https://arxiv.org/abs/2508.16190' }

  before { stub_request(:get, url).to_return(status: 200, body: fixture) }

  describe '#download' do
    it 'writes the abstract page HTML to the target path' do
      Dir.mktmpdir do |dir|
        target = File.join dir, '2508.16190-abstract.html'
        described_class.new(identifier, client: client).download to: target

        expect(File.read(target)).to eq fixture
      end
    end

    it 'requests the canonical abstract URL' do
      Dir.mktmpdir do |dir|
        described_class.new(identifier, client: client).download to: File.join(dir, 'a.html')

        expect(WebMock).to have_requested :get, url
      end
    end
  end
end
