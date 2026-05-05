RSpec.describe Arxiv::Downloader::FeedParser do
  let(:xml)      { File.read 'spec/fixtures/http/atom-2508.16190.xml' }
  let(:metadata) { described_class.new(xml).metadata }

  describe '#metadata' do
    it 'extracts the title' do
      expect(metadata.title).to eq 'ComicScene154: A Scene Dataset for Comic Analysis'
    end

    it 'extracts all authors in order' do
      expect(metadata.authors).to eq ['Sandro Paval', 'Ivan P. Yamshchikov', 'Pascal Meißner']
    end

    it 'extracts the abstract' do
      expect(metadata.abstract).to start_with('Comics offer a compelling yet under-explored domain')
      expect(metadata.abstract).to include('ComicScene154')
    end

    it 'extracts the published date' do
      expect(metadata.published).to eq Date.new(2025, 8, 22)
    end

    it 'extracts the updated date' do
      expect(metadata.updated).to eq Date.new(2025, 8, 22)
    end

    it 'extracts the arxiv ID (without version)' do
      expect(metadata.arxiv_id).to eq '2508.16190'
    end

    it 'derives the canonical abstract URL' do
      expect(metadata.arxiv_url).to eq 'https://arxiv.org/abs/2508.16190'
    end

    it 'derives the canonical PDF URL' do
      expect(metadata.pdf_url).to eq 'https://arxiv.org/pdf/2508.16190.pdf'
    end

    it 'extracts the primary category as id, name, group' do
      expect(metadata.primary_category).to include(
        id:    'cs.CL',
        name:  'Computation and Language',
        group: 'Computer Science'
      )
    end

    it 'includes the description on the primary category' do
      expect(metadata.primary_category[:description]).to start_with 'Covers natural language processing'
    end

    it 'extracts all categories as id, name, group' do
      expect(metadata.categories.length).to eq 1
      expect(metadata.categories.first).to include(
        id:    'cs.CL',
        name:  'Computation and Language',
        group: 'Computer Science'
      )
    end

    it 'returns nil for comment when none is present' do
      expect(metadata.comment).to be_nil
    end

    it 'returns nil for doi when none is present' do
      expect(metadata.doi).to be_nil
    end

    it 'returns nil for journal_ref when none is present' do
      expect(metadata.journal_ref).to be_nil
    end
  end

  describe '#metadata for a paper with comment, doi, and journal_ref' do
    let(:xml)      { File.read 'spec/fixtures/http/atom-1207.7214.xml' }
    let(:metadata) { described_class.new(xml).metadata }

    it 'extracts the comment' do
      expect(metadata.comment).to start_with '24 pages plus author list'
    end

    it 'extracts the doi' do
      expect(metadata.doi).to eq '10.1016/j.physletb.2012.08.020'
    end

    it 'extracts the journal_ref' do
      expect(metadata.journal_ref).to eq 'Phys.Lett. B716 (2012) 1-29'
    end
  end
end
