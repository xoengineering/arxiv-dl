require 'tmpdir'

RSpec.describe Arxiv::Downloader::Archive do
  let(:identifier) { Arxiv::Downloader::Identifier.new '2508.16190' }
  let(:expected_dir) { '2025/08/22/cs.CL/2508.16190-comicscene154-a-scene-dataset-for-comic-analysis' }
  let(:client) { Arxiv::Downloader::Client.new(rate_limit: 0) }

  let(:atom_url)     { 'https://export.arxiv.org/api/query?id_list=2508.16190' }
  let(:pdf_url)      { 'https://arxiv.org/pdf/2508.16190.pdf' }
  let(:abstract_url) { 'https://arxiv.org/abs/2508.16190' }
  let(:html_url)     { 'https://arxiv.org/html/2508.16190' }
  let(:src_url)      { 'https://arxiv.org/src/2508.16190' }
  let(:bibtex_url)   { 'https://arxiv.org/bibtex/2508.16190' }
  let(:x1_url)       { 'https://arxiv.org/html/2508.16190/x1.png' }
  let(:x2_url)       { 'https://arxiv.org/html/2508.16190/x2.png' }
  let(:css_url)      { 'https://arxiv.org/static/browse/0.3.4/css/ar5iv.0.7.9.min.css' }
  let(:js_url)       { 'https://arxiv.org/static/browse/0.3.4/js/addons_new.js' }
  let(:cdn_css_url)  { 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css' }
  let(:cdn_js_url)   { 'https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js' }

  before do
    stub_request(:get, atom_url).to_return(status: 200, body: File.read('spec/fixtures/http/atom-2508.16190.xml'))
    stub_request(:get, pdf_url).to_return(status: 200, body: File.binread('spec/fixtures/http/pdf-2508.16190.pdf'))
    stub_request(:get, abstract_url).to_return(status: 200, body: File.read('spec/fixtures/http/abstract-2508.16190.html'))
    stub_request(:get, html_url).to_return(status: 200, body: File.read('spec/fixtures/http/html-2508.16190.html'))
    stub_request(:get, src_url).to_return(status: 200, body: File.binread('spec/fixtures/http/src-fixture.tar.gz'))
    stub_request(:get, bibtex_url).to_return(status: 200, body: File.read('spec/fixtures/http/bibtex-2508.16190.bib'))
    stub_request(:get, x1_url).to_return(status: 200, body: File.binread('spec/fixtures/http/html-x1.png'))
    stub_request(:get, x2_url).to_return(status: 200, body: File.binread('spec/fixtures/http/html-x1.png'))
    stub_request(:get, css_url).to_return(status: 200, body: 'body{}')
    stub_request(:get, js_url).to_return(status: 200, body: 'function overlay(){}')
    stub_request(:get, cdn_css_url).to_return(status: 200, body: '.btn{}')
    stub_request(:get, cdn_js_url).to_return(status: 200, body: 'function noop(){}')
  end

  describe '#run' do
    it 'returns the absolute path of the paper directory' do
      Dir.mktmpdir do |root|
        path = described_class.new(identifier, root: root, client: client).run

        expect(path).to eq File.join(root, expected_dir)
      end
    end

    it 'creates the YYYY/MM/DD/<cat>/<id>-<slug>/ directory' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        expect(Dir).to exist File.join(root, expected_dir)
      end
    end

    it 'writes the PDF' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        pdf = File.join root, expected_dir, '2508.16190.pdf'
        expect(File.binread(pdf)).to eq File.binread('spec/fixtures/http/pdf-2508.16190.pdf')
      end
    end

    it 'writes the abstract HTML' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        abstract = File.join root, expected_dir, '2508.16190-abstract.html'
        expect(File.read(abstract)).to eq File.read('spec/fixtures/http/abstract-2508.16190.html')
      end
    end

    it 'writes all four metadata sidecars' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        paper_dir = File.join root, expected_dir
        %w[metadata.md metadata.yaml metadata.json metadata.bib].each do |name|
          expect(File).to exist File.join(paper_dir, name)
        end
      end
    end

    it 'extracts the source archive into src/' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        src_dir = File.join root, expected_dir, 'src'
        expect(File).to exist File.join(src_dir, 'main.tex')
        expect(File).to exist File.join(src_dir, 'refs.bib')
        expect(File).to exist File.join(src_dir, 'figures', 'figure1.png')
      end
    end

    it 'writes the HTML archive into html/' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        html_dir = File.join root, expected_dir, 'html'
        expect(File).to exist File.join(html_dir, '2508.16190.html')
        expect(File).to exist File.join(html_dir, 'x1.png')
        expect(File).to exist File.join(html_dir, 'x2.png')
      end
    end

    it 'caches shared assets under _shared/' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        expect(File).to exist File.join(root, '_shared', 'arxiv.org', 'static', 'browse', '0.3.4', 'css',
                                        'ar5iv.0.7.9.min.css')
        expect(File).to exist File.join(root, '_shared', 'cdn.jsdelivr.net', 'npm', 'bootstrap@5.3.0', 'dist', 'css',
                                        'bootstrap.min.css')
      end
    end
  end
end
