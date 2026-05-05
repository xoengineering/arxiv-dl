require 'tmpdir'
require 'yaml'

RSpec.describe Arxiv::Downloader::Metadata::YAML do
  let(:metadata) do
    Arxiv::Downloader::Metadata.new(
      arxiv_id:         '2508.16190',
      arxiv_url:        'https://arxiv.org/abs/2508.16190',
      pdf_url:          'https://arxiv.org/pdf/2508.16190.pdf',
      title:            'ComicScene154',
      authors:          ['Sandro Paval', 'Ivan P. Yamshchikov'],
      abstract:         "Two-line\nabstract.",
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
    it 'writes metadata.yaml into the target directory' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        expect(File).to exist File.join(dir, 'metadata.yaml')
      end
    end

    it 'serializes metadata as YAML with string keys round-trippable to a Hash' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        loaded = YAML.safe_load_file(File.join(dir, 'metadata.yaml'), permitted_classes: [Date])
        expect(loaded.fetch('arxiv_id')).to eq '2508.16190'
        expect(loaded.fetch('title')).to    eq 'ComicScene154'
        expect(loaded.fetch('authors')).to  eq ['Sandro Paval', 'Ivan P. Yamshchikov']
        expect(loaded.fetch('published')).to eq Date.new(2025, 8, 22)
      end
    end

    it 'serializes nested category hashes with string keys' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        loaded = YAML.safe_load_file(File.join(dir, 'metadata.yaml'), permitted_classes: [Date])
        expect(loaded.fetch('primary_category')).to eq(
          'id'    => 'cs.CL',
          'name'  => 'Computation and Language',
          'group' => 'Computer Science'
        )
      end
    end
  end
end
