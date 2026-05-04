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
  end
end
