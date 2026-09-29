require 'tmpdir'

RSpec.describe Arxiv::Downloader::SourceArchive do
  let(:identifier) { Arxiv::Downloader::Identifier.new '2508.16190' }
  let(:client)     { Arxiv::Downloader::Client.new(rate_limit: 0) }
  let(:fixture)    { File.binread 'spec/fixtures/http/src-fixture.tar.gz' }
  let(:url)        { 'https://arxiv.org/src/2508.16190' }

  before { stub_request(:get, url).to_return(status: 200, body: fixture) }

  describe '#download' do
    it 'extracts the tarball into the target directory' do
      Dir.mktmpdir do |dir|
        target = File.join dir, 'src'
        described_class.new(identifier, client: client).download to: target

        expect(File.read(File.join(target, 'main.tex'))).to include '\documentclass'
        expect(File.read(File.join(target, 'refs.bib'))).to include '@article'
      end
    end

    it 'creates nested directories from the tarball' do
      Dir.mktmpdir do |dir|
        target = File.join dir, 'src'
        described_class.new(identifier, client: client).download to: target

        expect(File).to exist File.join(target, 'figures', 'figure1.png')
      end
    end

    it 'preserves binary file contents' do
      Dir.mktmpdir do |dir|
        target = File.join dir, 'src'
        described_class.new(identifier, client: client).download to: target

        expect(File.binread(File.join(target, 'figures', 'figure1.png')).bytes.first(4)).to eq [0x89, 0x50, 0x4e, 0x47]
      end
    end

    it 'creates the target directory if missing' do
      Dir.mktmpdir do |dir|
        target = File.join dir, 'does', 'not', 'exist', 'src'
        described_class.new(identifier, client: client).download to: target

        expect(Dir).to exist target
      end
    end

    it 'does not leave the tarball on disk' do
      Dir.mktmpdir do |dir|
        target = File.join dir, 'src'
        described_class.new(identifier, client: client).download to: target

        tarballs = Dir.glob(File.join(dir, '**', '*.tar.gz'))
        expect(tarballs).to be_empty
      end
    end

    it 'requests the canonical source URL' do
      Dir.mktmpdir do |dir|
        described_class.new(identifier, client: client).download to: File.join(dir, 'src')

        expect(WebMock).to have_requested :get, url
      end
    end

    context 'with a versioned identifier' do
      let(:identifier) { Arxiv::Downloader::Identifier.new '2508.16190v1' }
      let(:url)        { 'https://arxiv.org/src/2508.16190v1' }

      it 'requests that version' do
        Dir.mktmpdir do |dir|
          described_class.new(identifier, client: client).download to: File.join(dir, 'src')

          expect(WebMock).to have_requested :get, url
        end
      end
    end

    context 'when the tarball has entries that escape the target directory' do
      let(:fixture) { File.binread 'spec/fixtures/http/src-path-traversal.tar.gz' }

      it 'skips the escaping entries and extracts the rest' do
        Dir.mktmpdir do |dir|
          target = File.join dir, 'paper', 'src'
          described_class.new(identifier, client: client).download to: target

          expect(File).to     exist File.join(target, 'main.tex')
          expect(File).not_to exist File.join(dir, 'paper', 'escaped.txt')
          expect(File).not_to exist File.join(dir, 'paper', 'escaped-nested.txt')
        end
      end
    end

    context 'when the source is a single gzipped file' do
      let(:fixture) { File.binread 'spec/fixtures/http/src-single-file.gz' }

      it 'writes the decompressed file under its original gzip name' do
        Dir.mktmpdir do |dir|
          target = File.join dir, 'src'
          described_class.new(identifier, client: client).download to: target

          expect(File.read(File.join(target, 'main.tex'))).to include 'Single-file submission.'
        end
      end
    end

    context 'when the source is a PDF (PDF-only submission)' do
      let(:fixture) { File.binread 'spec/fixtures/http/pdf-2508.16190.pdf' }

      it 'writes nothing, since the PDF is already archived' do
        Dir.mktmpdir do |dir|
          target = File.join dir, 'src'
          described_class.new(identifier, client: client).download to: target

          expect(File).not_to exist target
        end
      end
    end

    context 'when the source is in an unrecognized format' do
      let(:fixture) { 'plain bytes' }

      it 'keeps the raw bytes as src/<id>' do
        Dir.mktmpdir do |dir|
          target = File.join dir, 'src'
          described_class.new(identifier, client: client).download to: target

          expect(File.binread(File.join(target, '2508.16190'))).to eq 'plain bytes'
        end
      end

      context 'with a legacy identifier' do
        let(:identifier) { Arxiv::Downloader::Identifier.new 'cs/0002001v1' }
        let(:url)        { 'https://arxiv.org/src/cs/0002001v1' }

        it 'names the file without the legacy /' do
          Dir.mktmpdir do |dir|
            target = File.join dir, 'src'
            described_class.new(identifier, client: client).download to: target

            expect(File.binread(File.join(target, 'cs-0002001v1'))).to eq 'plain bytes'
          end
        end
      end
    end
  end
end
