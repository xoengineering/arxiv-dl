require 'tmpdir'

RSpec.describe Arxiv::Downloader::Archive do
  let(:identifier) { Arxiv::Downloader::Identifier.new '2508.16190' }
  let(:expected_dir) { '2025/08/22/cs.CL/2508.16190-comicscene154-a-scene-dataset-for-comic-analysis' }
  let(:client) { Arxiv::Downloader::Client.new(rate_limit: 0) }

  let(:atom_url)     { 'https://export.arxiv.org/api/query?id_list=2508.16190' }
  let(:pdf_url)      { 'https://arxiv.org/pdf/2508.16190v1.pdf' }
  let(:abstract_url) { 'https://arxiv.org/abs/2508.16190v1' }
  let(:html_url)     { 'https://arxiv.org/html/2508.16190v1' }
  let(:src_url)      { 'https://arxiv.org/src/2508.16190v1' }
  let(:bibtex_url)   { 'https://arxiv.org/bibtex/2508.16190' }
  let(:x1_url)       { 'https://arxiv.org/html/2508.16190v1/x1.png' }
  let(:x2_url)       { 'https://arxiv.org/html/2508.16190v1/x2.png' }
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

    it 'creates the YYYY/MM/DD/<cat>/<id>-<slug>/ directory, flat for a single-version paper' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        expect(Dir).to exist File.join(root, expected_dir)
      end
    end

    it 'writes the PDF' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        pdf = File.join root, expected_dir, '2508.16190v1.pdf'
        expect(File.binread(pdf)).to eq File.binread('spec/fixtures/http/pdf-2508.16190.pdf')
      end
    end

    it 'writes the abstract HTML' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        abstract = File.join root, expected_dir, '2508.16190v1-abstract.html'
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
        expect(File).to exist File.join(html_dir, '2508.16190v1.html')
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

    it 'links the archived HTML to cached assets that exist' do
      Dir.mktmpdir do |root|
        described_class.new(identifier, root: root, client: client).run

        html_dir = File.join root, expected_dir, 'html'
        document = Nokogiri::HTML File.read(File.join(html_dir, '2508.16190v1.html'))
        shared   = document.css('link[rel="stylesheet"]').map { it['href'] }.select { it.include? '_shared' }

        expect(shared).not_to be_empty
        shared.each { expect(File).to exist File.expand_path(it, html_dir) }
      end
    end

    context 'when the version is already archived' do
      it 'skips the downloads and returns the existing folder' do
        Dir.mktmpdir do |root|
          described_class.new(identifier, root: root, client: client).run
          path = described_class.new(identifier, root: root, client: client).run

          expect(path).to eq File.join(root, expected_dir)
          expect(WebMock).to have_requested(:get, pdf_url).once
        end
      end
    end

    context 'when a download fails partway' do
      let(:src_body) { File.binread 'spec/fixtures/http/src-fixture.tar.gz' }

      before { stub_request(:get, src_url).to_return({ status: 500 }, { status: 200, body: src_body }) }

      it 'leaves no paper folder, so the version is not mistaken for archived' do
        Dir.mktmpdir do |root|
          archive = described_class.new(identifier, root: root, client: client)

          expect { archive.run }.to raise_error Arxiv::Downloader::HTTPError
          expect(File).not_to exist File.join(root, expected_dir)
        end
      end

      it 'completes on the next run' do
        Dir.mktmpdir do |root|
          expect { described_class.new(identifier, root: root, client: client).run }
            .to raise_error Arxiv::Downloader::HTTPError
          described_class.new(identifier, root: root, client: client).run

          expect(File).to     exist File.join(root, expected_dir, 'src', 'main.tex')
          expect(File).not_to exist File.join(root, "#{expected_dir}.partial")
        end
      end
    end

    context 'with a versioned identifier' do
      let(:identifier) { Arxiv::Downloader::Identifier.new '2508.16190v1' }
      let(:atom_url)   { 'https://export.arxiv.org/api/query?id_list=2508.16190v1' }

      it 'asks the API for that version' do
        Dir.mktmpdir do |root|
          path = described_class.new(identifier, root: root, client: client).run

          expect(WebMock).to have_requested :get, atom_url
          expect(path).to eq File.join(root, expected_dir)
        end
      end
    end

    context 'when another version already has a v<N>/ folder' do
      it 'archives this version into its own v<N>/ folder' do
        Dir.mktmpdir do |root|
          FileUtils.mkdir_p File.join(root, expected_dir, 'v2')

          path = described_class.new(identifier, root: root, client: client).run

          expect(path).to eq File.join(root, expected_dir, 'v1')
          expect(File).to exist File.join(path, '2508.16190v1.pdf')
        end
      end
    end

    context 'when another version is already archived flat' do
      it 'moves that version into its v<N>/ folder and archives this one beside it' do
        Dir.mktmpdir do |root|
          paper_dir = File.join root, expected_dir
          earlier   = Arxiv::Downloader::FeedParser.new(File.read('spec/fixtures/http/atom-2508.16190.xml')).metadata
          Arxiv::Downloader::Metadata::YAML.new(earlier.with(version: 2)).write to: paper_dir

          path = described_class.new(identifier, root: root, client: client).run

          expect(path).to eq File.join(paper_dir, 'v1')
          expect(File).to     exist File.join(paper_dir, 'v1', '2508.16190v1.pdf')
          expect(File).to     exist File.join(paper_dir, 'v2', 'metadata.yaml')
          expect(File).not_to exist File.join(paper_dir, 'metadata.yaml')
        end
      end
    end
  end
end
