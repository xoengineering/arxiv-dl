require 'tmpdir'

RSpec.describe Arxiv::Downloader::PaperFolder do
  # writes a real metadata.yaml recording `version`, the marker of a flat archive
  def archive_flat version, into:
    metadata = Arxiv::Downloader::FeedParser.new(File.read('spec/fixtures/http/atom-2508.16190.xml')).metadata
    Arxiv::Downloader::Metadata::YAML.new(metadata.with(version: version)).write to: into
  end

  describe '#archived?' do
    it 'is false for a missing folder' do
      Dir.mktmpdir do |root|
        expect(described_class.new(File.join(root, 'paper')).archived?(1)).to be false
      end
    end

    it 'is true for the version held flat' do
      Dir.mktmpdir do |root|
        archive_flat 1, into: root

        expect(described_class.new(root).archived?(1)).to be true
        expect(described_class.new(root).archived?(2)).to be false
      end
    end

    it 'is true for a version with its own v<N>/ folder' do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p File.join(root, 'v2')

        expect(described_class.new(root).archived?(2)).to be true
        expect(described_class.new(root).archived?(1)).to be false
      end
    end
  end

  describe '#location_of' do
    it 'is the folder itself for the version held flat' do
      Dir.mktmpdir do |root|
        archive_flat 1, into: root

        expect(described_class.new(root).location_of(1)).to eq root
      end
    end

    it 'is v<N>/ otherwise' do
      Dir.mktmpdir do |root|
        expect(described_class.new(root).location_of(2)).to eq File.join(root, 'v2')
      end
    end
  end

  describe '#destination_for' do
    it 'is the folder itself for v1 of a new paper' do
      Dir.mktmpdir do |root|
        path = File.join root, 'paper'

        expect(described_class.new(path).destination_for(1)).to eq path
      end
    end

    it 'is v<N>/ for a later version of a new paper' do
      Dir.mktmpdir do |root|
        path = File.join root, 'paper'

        expect(described_class.new(path).destination_for(2)).to eq File.join(path, 'v2')
      end
    end

    it 'is v1/ when other versions already have folders' do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p File.join(root, 'v2')

        expect(described_class.new(root).destination_for(1)).to eq File.join(root, 'v1')
      end
    end

    it 'is v1/ when an interrupted later version left a .partial folder' do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p File.join(root, 'v2.partial')

        expect(described_class.new(root).destination_for(1)).to eq File.join(root, 'v1')
      end
    end
  end

  describe '#unflatten!' do
    it 'moves the flat version into v<N>/' do
      Dir.mktmpdir do |root|
        archive_flat 1, into: root
        File.write File.join(root, '2508.16190v1.pdf'), 'pdf'

        described_class.new(root).unflatten!

        expect(File).to     exist File.join(root, 'v1', '2508.16190v1.pdf')
        expect(File).to     exist File.join(root, 'v1', 'metadata.yaml')
        expect(File).not_to exist File.join(root, 'metadata.yaml')
        expect(described_class.new(root).location_of(1)).to eq File.join(root, 'v1')
      end
    end

    it 'deepens relative links into _shared/ by one level, leaving page-relative links alone' do
      Dir.mktmpdir do |root|
        archive_flat 1, into: root
        FileUtils.mkdir_p File.join(root, 'html')
        File.write File.join(root, 'html', '2508.16190v1.html'), <<~HTML
          <html><head><link rel="stylesheet" href="../../_shared/arxiv.org/a.css"></head>
          <body><img src="x1.png"><script src="../../_shared/cdn.example/b.js"></script></body></html>
        HTML

        described_class.new(root).unflatten!

        html = File.read File.join(root, 'v1', 'html', '2508.16190v1.html')
        expect(html).to include 'href="../../../_shared/arxiv.org/a.css"'
        expect(html).to include 'src="../../../_shared/cdn.example/b.js"'
        expect(html).to include 'src="x1.png"'
      end
    end

    it 'does nothing when the folder is not flat' do
      Dir.mktmpdir do |root|
        FileUtils.mkdir_p File.join(root, 'v2')

        described_class.new(root).unflatten!

        expect(Dir.children(root)).to eq ['v2']
      end
    end
  end
end
