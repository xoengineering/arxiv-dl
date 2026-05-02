require 'tmpdir'

RSpec.describe Arxiv::Downloader::PDF do
  let(:identifier) { Arxiv::Downloader::Identifier.new '2508.16190' }
  let(:client)     { Arxiv::Downloader::Client.new(rate_limit: 0) }
  let(:fixture)    { File.binread 'spec/fixtures/http/pdf-2508.16190.pdf' }
  let(:url)        { 'https://arxiv.org/pdf/2508.16190.pdf' }

  before { stub_request(:get, url).to_return(status: 200, body: fixture) }

  describe '#download' do
    it 'writes the PDF body to the target path' do
      Dir.mktmpdir do |dir|
        target = File.join dir, '2508.16190.pdf'
        described_class.new(identifier, client: client).download to: target

        expect(File.binread(target)).to eq fixture
      end
    end

    it 'requests the canonical PDF URL' do
      Dir.mktmpdir do |dir|
        target = File.join dir, '2508.16190.pdf'
        described_class.new(identifier, client: client).download to: target

        expect(WebMock).to have_requested(:get, url)
      end
    end
  end
end
