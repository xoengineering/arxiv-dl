require 'tmpdir'

RSpec.describe Arxiv::Downloader::CLI do
  let(:stdout) { StringIO.new }
  let(:expected_dir) { '2025/08/22/cs.CL/2508.16190-comicscene154-a-scene-dataset-for-comic-analysis' }
  let(:stderr) { StringIO.new }

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

  def with_env vars
    previous = vars.to_h { |key, _| [key.to_s, ENV.fetch(key.to_s, nil)] }
    vars.each { |key, value| ENV[key.to_s] = value }
    yield
  ensure
    previous.each { |key, value| ENV[key] = value }
  end

  describe '#run' do
    context 'with a target id and -p path' do
      it 'returns 0 on success' do
        Dir.mktmpdir do |root|
          status = described_class.new(['-p', root, '--rate-limit', '0', '2508.16190'], stdout: stdout, stderr: stderr).run

          expect(status).to eq 0
        end
      end

      it 'prints the paper directory to stdout by default' do
        Dir.mktmpdir do |root|
          described_class.new(['-p', root, '--rate-limit', '0', '2508.16190'], stdout: stdout, stderr: stderr).run

          expect(stdout.string).to eq "#{File.join(root, expected_dir)}\n"
        end
      end

      it 'downloads all artifacts to the target directory' do
        Dir.mktmpdir do |root|
          described_class.new(['-p', root, '--rate-limit', '0', '2508.16190'], stdout: stdout, stderr: stderr).run

          expect(File).to exist File.join(root, expected_dir, '2508.16190.pdf')
          expect(File).to exist File.join(root, expected_dir, 'metadata.md')
        end
      end
    end

    context 'with -q (quiet)' do
      it 'prints nothing on success' do
        Dir.mktmpdir do |root|
          described_class.new(['-p', root, '--rate-limit', '0', '-q', '2508.16190'], stdout: stdout, stderr: stderr).run

          expect(stdout.string).to be_empty
        end
      end
    end

    context 'with -v (verbose)' do
      it 'prints step lines and request logs to stdout' do
        Dir.mktmpdir do |root|
          described_class.new(['-p', root, '--rate-limit', '0', '-v', '2508.16190'], stdout: stdout, stderr: stderr).run

          expect(stdout.string).to include '==> Downloading 2508.16190'
          expect(stdout.string).to include "==> GET #{pdf_url}"
        end
      end
    end

    context 'with -v and -q together' do
      it 'exits non-zero with an error on stderr' do
        status = described_class.new(['-v', '-q', '2508.16190'], stdout: stdout, stderr: stderr).run

        expect(status).not_to eq 0
        expect(stderr.string).to include 'mutually exclusive'
      end
    end

    context 'with --version' do
      it 'prints the version and exits 0' do
        status = described_class.new(['--version'], stdout: stdout, stderr: stderr).run

        expect(status).to eq 0
        expect(stdout.string).to include Arxiv::Downloader::VERSION
      end
    end

    context 'with -h' do
      it 'prints help and exits 0' do
        status = described_class.new(['-h'], stdout: stdout, stderr: stderr).run

        expect(status).to eq 0
        expect(stdout.string).to include 'Usage'
      end
    end

    context 'with no targets' do
      it 'prints help to stderr and exits non-zero' do
        status = described_class.new([], stdout: stdout, stderr: stderr).run

        expect(status).not_to eq 0
        expect(stderr.string).to include 'Usage'
      end
    end

    context 'with multiple targets' do
      it 'downloads each one' do
        Dir.mktmpdir do |root|
          described_class.new(['-p', root, '--rate-limit', '0', '2508.16190', '2508.16190'], stdout: stdout,
                                                                                             stderr: stderr).run

          # Both targets land at the same path; output line is printed twice
          expect(stdout.string.lines.count).to eq 2
        end
      end
    end

    context 'with ENV ARXIV_DOWNLOAD_PATH' do
      it 'uses ENV when -p is not provided' do
        Dir.mktmpdir do |root|
          with_env ARXIV_DOWNLOAD_PATH: root, ARXIV_RATE_LIMIT: '0' do
            described_class.new(['2508.16190'], stdout: stdout, stderr: stderr).run
          end

          expect(File).to exist File.join(root, expected_dir, '2508.16190.pdf')
        end
      end
    end

    context 'with both ENV and -p' do
      it 'CLI flag wins over ENV' do
        Dir.mktmpdir do |env_root|
          Dir.mktmpdir do |flag_root|
            with_env ARXIV_DOWNLOAD_PATH: env_root, ARXIV_RATE_LIMIT: '0' do
              described_class.new(['-p', flag_root, '2508.16190'], stdout: stdout, stderr: stderr).run
            end

            expect(File).to     exist File.join(flag_root, expected_dir, '2508.16190.pdf')
            expect(File).not_to exist File.join(env_root, expected_dir, '2508.16190.pdf')
          end
        end
      end
    end
  end
end
