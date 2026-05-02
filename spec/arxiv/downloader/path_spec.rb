RSpec.describe Arxiv::Downloader::Path do
  describe '#to_s' do
    context 'with a modern arxiv paper (ComicScene154)' do
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

      it 'returns YYYY/MM/DD/<category>/<id>-<slug>' do
        expect(described_class.new(metadata).to_s)
          .to eq '2025/08/22/cs.CL/2508.16190-comicscene154-a-scene-dataset-for-comic-analysis'
      end
    end

    context 'with a legacy arxiv paper (cs/0002001-style)' do
      let(:metadata) do
        Arxiv::Downloader::Metadata.new(
          arxiv_id:         'cs/0002001',
          arxiv_url:        'https://arxiv.org/abs/cs/0002001',
          pdf_url:          'https://arxiv.org/pdf/cs/0002001.pdf',
          title:            'A Foundational Computer Science Paper',
          authors:          ['A. N. Author'],
          abstract:         'Lorem ipsum...',
          published:        Date.new(2000, 2, 15),
          updated:          Date.new(2000, 2, 15),
          primary_category: { id: 'cs.AI', name: 'Artificial Intelligence', group: 'Computer Science' },
          categories:       [{ id: 'cs.AI', name: 'Artificial Intelligence', group: 'Computer Science' }],
          comment:          nil,
          doi:              nil,
          journal_ref:      nil
        )
      end

      it 'replaces the legacy / in the id with a -' do
        expect(described_class.new(metadata).to_s)
          .to eq '2000/02/15/cs.AI/cs-0002001-a-foundational-computer-science-paper'
      end
    end

    context 'with a legacy paper with subject class (math.GT/0312088)' do
      let(:metadata) do
        Arxiv::Downloader::Metadata.new(
          arxiv_id:         'math.GT/0312088',
          arxiv_url:        'https://arxiv.org/abs/math.GT/0312088',
          pdf_url:          'https://arxiv.org/pdf/math.GT/0312088.pdf',
          title:            'On Some Knot Invariant',
          authors:          ['M. Athematician'],
          abstract:         '...',
          published:        Date.new(2003, 12, 5),
          updated:          Date.new(2003, 12, 5),
          primary_category: { id: 'math.GT', name: 'Geometric Topology', group: 'Mathematics' },
          categories:       [{ id: 'math.GT', name: 'Geometric Topology', group: 'Mathematics' }],
          comment:          nil,
          doi:              nil,
          journal_ref:      nil
        )
      end

      it 'replaces the / and keeps the subject class' do
        expect(described_class.new(metadata).to_s)
          .to eq '2003/12/05/math.GT/math.GT-0312088-on-some-knot-invariant'
      end
    end
  end
end
