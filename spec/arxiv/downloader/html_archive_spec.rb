require 'tmpdir'

RSpec.describe Arxiv::Downloader::HTMLArchive do
  let(:identifier)   { Arxiv::Downloader::Identifier.new '2508.16190' }
  let(:client)       { Arxiv::Downloader::Client.new(rate_limit: 0) }
  let(:html_fixture) { File.read 'spec/fixtures/http/html-2508.16190.html' }
  let(:png_fixture)  { File.binread 'spec/fixtures/http/html-x1.png' }

  let(:html_url) { 'https://arxiv.org/html/2508.16190' }
  let(:x1_url)   { 'https://arxiv.org/html/2508.16190/x1.png' }
  let(:x2_url)   { 'https://arxiv.org/html/2508.16190/x2.png' }
  let(:css_url)  { 'https://arxiv.org/static/browse/0.3.4/css/ar5iv.0.7.9.min.css' }
  let(:cdn_css)  { 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css' }
  let(:cdn_js)   { 'https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js' }

  before do
    stub_request(:get, html_url).to_return(status: 200, body: html_fixture)
    stub_request(:get, x1_url).to_return(status: 200, body: png_fixture)
    stub_request(:get, x2_url).to_return(status: 200, body: png_fixture)
    stub_request(:get, css_url).to_return(status: 200, body: 'body{}')
    stub_request(:get, cdn_css).to_return(status: 200, body: '.btn{}')
    stub_request(:get, cdn_js).to_return(status: 200, body: 'function noop(){}')
  end

  describe '#download' do
    it 'writes the HTML to <dir>/<id>.html' do
      Dir.mktmpdir do |root|
        html_dir = File.join root, 'html'
        cache    = Arxiv::Downloader::AssetsCache.new root: root, client: client
        described_class.new(identifier, client: client, assets_cache: cache).download to: html_dir

        expect(File).to exist File.join(html_dir, '2508.16190.html')
      end
    end

    it 'fetches relative images as siblings of the HTML file' do
      Dir.mktmpdir do |root|
        html_dir = File.join root, 'html'
        cache    = Arxiv::Downloader::AssetsCache.new root: root, client: client
        described_class.new(identifier, client: client, assets_cache: cache).download to: html_dir

        expect(File.binread(File.join(html_dir, 'x1.png'))).to eq png_fixture
        expect(File.binread(File.join(html_dir, 'x2.png'))).to eq png_fixture
      end
    end

    it 'leaves the relative image src unchanged' do
      Dir.mktmpdir do |root|
        html_dir = File.join root, 'html'
        cache    = Arxiv::Downloader::AssetsCache.new root: root, client: client
        described_class.new(identifier, client: client, assets_cache: cache).download to: html_dir

        rewritten = File.read File.join(html_dir, '2508.16190.html')
        expect(rewritten).to include 'src="x1.png"'
        expect(rewritten).to include 'src="x2.png"'
      end
    end

    it 'caches same-host /static/ assets under _shared/' do
      Dir.mktmpdir do |root|
        html_dir = File.join root, 'html'
        cache    = Arxiv::Downloader::AssetsCache.new root: root, client: client
        described_class.new(identifier, client: client, assets_cache: cache).download to: html_dir

        cached = File.join root, '_shared', 'arxiv.org', 'static', 'browse', '0.3.4', 'css', 'ar5iv.0.7.9.min.css'
        expect(File).to exist cached
      end
    end

    it 'caches CDN assets under _shared/' do
      Dir.mktmpdir do |root|
        html_dir = File.join root, 'html'
        cache    = Arxiv::Downloader::AssetsCache.new root: root, client: client
        described_class.new(identifier, client: client, assets_cache: cache).download to: html_dir

        bootstrap = File.join root, '_shared', 'cdn.jsdelivr.net', 'npm', 'bootstrap@5.3.0', 'dist', 'css',
                              'bootstrap.min.css'
        html2     = File.join root, '_shared', 'cdn.jsdelivr.net', 'npm', 'html2canvas@1.4.1', 'dist', 'html2canvas.min.js'
        expect(File).to exist bootstrap
        expect(File).to exist html2
      end
    end

    it 'rewrites cached asset hrefs to relative paths into _shared/' do
      Dir.mktmpdir do |root|
        html_dir = File.join root, 'html'
        cache    = Arxiv::Downloader::AssetsCache.new root: root, client: client
        described_class.new(identifier, client: client, assets_cache: cache).download to: html_dir

        rewritten = File.read File.join(html_dir, '2508.16190.html')
        expect(rewritten).to include 'href="../_shared/arxiv.org/static/browse/0.3.4/css/ar5iv.0.7.9.min.css"'
        expect(rewritten).to include 'href="../_shared/cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"'
        expect(rewritten).to include 'src="../_shared/cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"'
      end
    end

    it 'creates the target directory if missing' do
      Dir.mktmpdir do |root|
        html_dir = File.join root, 'does', 'not', 'exist', 'html'
        cache    = Arxiv::Downloader::AssetsCache.new root: root, client: client
        described_class.new(identifier, client: client, assets_cache: cache).download to: html_dir

        expect(File).to exist File.join(html_dir, '2508.16190.html')
      end
    end
  end
end
