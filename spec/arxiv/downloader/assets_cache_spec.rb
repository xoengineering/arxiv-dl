require 'tmpdir'

RSpec.describe Arxiv::Downloader::AssetsCache do
  let(:client)    { Arxiv::Downloader::Client.new(rate_limit: 0) }
  let(:css_url)   { 'https://arxiv.org/static/browse/0.3.4/css/ar5iv.0.7.9.min.css' }
  let(:cdn_url)   { 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css' }
  let(:css_body)  { 'body { color: red; }' }
  let(:cdn_body)  { '.btn { padding: 0; }' }

  before do
    stub_request(:get, css_url).to_return(status: 200, body: css_body)
    stub_request(:get, cdn_url).to_return(status: 200, body: cdn_body)
  end

  describe '#fetch' do
    it 'downloads to _shared/<host>/<path> and returns the local path' do
      Dir.mktmpdir do |root|
        cache = described_class.new(root: root, client: client)

        path = cache.fetch css_url

        expect(path).to eq File.join(root, '_shared', 'arxiv.org', 'static', 'browse', '0.3.4', 'css', 'ar5iv.0.7.9.min.css')
        expect(File.read(path)).to eq css_body
      end
    end

    it 'handles CDN-hosted assets under their own host directory' do
      Dir.mktmpdir do |root|
        cache = described_class.new(root: root, client: client)

        path = cache.fetch cdn_url

        expect(path).to eq File.join(root, '_shared', 'cdn.jsdelivr.net', 'npm', 'bootstrap@5.3.0', 'dist', 'css',
                                     'bootstrap.min.css')
        expect(File.read(path)).to eq cdn_body
      end
    end

    it 'skips the download when the file already exists' do
      Dir.mktmpdir do |root|
        cache = described_class.new(root: root, client: client)

        cache.fetch css_url
        cache.fetch css_url

        expect(WebMock).to have_requested(:get, css_url).once
      end
    end

    it 'creates intermediate directories' do
      Dir.mktmpdir do |root|
        cache = described_class.new(root: root, client: client)

        cache.fetch css_url

        expect(Dir).to exist File.join(root, '_shared', 'arxiv.org', 'static', 'browse', '0.3.4', 'css')
      end
    end

    it 'writes binary content correctly' do
      binary_url  = 'https://example.com/image.png'
      binary_body = "\x89PNG\r\n\x1a\n\x00\x00\x00".b
      stub_request(:get, binary_url).to_return(status: 200, body: binary_body)

      Dir.mktmpdir do |root|
        cache = described_class.new(root: root, client: client)

        path = cache.fetch binary_url

        expect(File.binread(path)).to eq binary_body
      end
    end
  end
end
