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
  end
end
