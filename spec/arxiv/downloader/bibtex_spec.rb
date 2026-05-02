RSpec.describe Arxiv::Downloader::Bibtex do
  let(:metadata) do
    Arxiv::Downloader::Metadata.new(
      arxiv_id:         '2508.16190',
      arxiv_url:        'https://arxiv.org/abs/2508.16190',
      pdf_url:          'https://arxiv.org/pdf/2508.16190.pdf',
      title:            'ComicScene154: A Scene Dataset for Comic Analysis',
      authors:          ['Sandro Paval', 'Ivan P. Yamshchikov', 'Pascal Meißner'],
      abstract:         'Comics offer a compelling yet under-explored domain...',
      published:        Date.new(2025, 8, 22),
      updated:          Date.new(2025, 8, 22),
      primary_category: { id: 'cs.CL', name: 'Computation and Language', group: 'Computer Science' },
      categories:       [{ id: 'cs.CL', name: 'Computation and Language', group: 'Computer Science' }],
      comment:          nil,
      doi:              nil,
      journal_ref:      nil
    )
  end

  describe '#synthesize' do
    subject(:bibtex) { described_class.new(metadata).synthesize }

    it 'produces a @misc entry with all metadata fields' do
      expect(bibtex).to include '@misc{paval2025comicscene154,'
      expect(bibtex).to include 'title={ComicScene154: A Scene Dataset for Comic Analysis}'
      expect(bibtex).to include 'author={Sandro Paval and Ivan P. Yamshchikov and Pascal Meißner}'
      expect(bibtex).to include 'year={2025}'
      expect(bibtex).to include 'eprint={2508.16190}'
      expect(bibtex).to include 'archivePrefix={arXiv}'
      expect(bibtex).to include 'primaryClass={cs.CL}'
      expect(bibtex).to include 'url={https://arxiv.org/abs/2508.16190}'
    end
  end
end
