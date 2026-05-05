require 'json'
require 'tmpdir'

RSpec.describe Arxiv::Downloader::Metadata::JSON do
  let(:metadata) do
    Arxiv::Downloader::Metadata.new(
      arxiv_id:         '2508.16190',
      arxiv_url:        'https://arxiv.org/abs/2508.16190',
      pdf_url:          'https://arxiv.org/pdf/2508.16190.pdf',
      title:            'ComicScene154',
      authors:          ['Sandro Paval'],
      abstract:         'Brief.',
      published:        Date.new(2025, 8, 22),
      updated:          Date.new(2025, 8, 23),
      primary_category: { id: 'cs.CL', name: 'Computation and Language', group: 'Computer Science' },
      categories:       [{ id: 'cs.CL', name: 'Computation and Language', group: 'Computer Science' }],
      comment:          nil,
      doi:              nil,
      journal_ref:      nil
    )
  end

  describe '#write' do
    it 'writes metadata.json into the target directory' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        expect(File).to exist File.join(dir, 'metadata.json')
      end
    end

    it 'serializes metadata as JSON with string keys' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        loaded = JSON.parse File.read(File.join(dir, 'metadata.json'))
        expect(loaded.fetch('arxiv_id')).to eq '2508.16190'
        expect(loaded.fetch('authors')).to  eq ['Sandro Paval']
      end
    end

    it 'serializes dates as ISO 8601 strings' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        loaded = JSON.parse File.read(File.join(dir, 'metadata.json'))
        expect(loaded.fetch('published')).to eq '2025-08-22'
        expect(loaded.fetch('updated')).to   eq '2025-08-23'
      end
    end

    it 'serializes nested category hashes with string keys' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        loaded = JSON.parse File.read(File.join(dir, 'metadata.json'))
        expect(loaded.fetch('primary_category')).to eq(
          'id'    => 'cs.CL',
          'name'  => 'Computation and Language',
          'group' => 'Computer Science'
        )
      end
    end

    it 'pretty-prints with 2-space indent' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        body = File.read File.join(dir, 'metadata.json')
        expect(body).to include "\n  \"arxiv_id\""
      end
    end
  end
end
