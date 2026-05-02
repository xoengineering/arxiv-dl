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

  describe '#fetch' do
    let(:client)  { Arxiv::Downloader::Client.new(rate_limit: 0) }
    let(:url)     { 'https://arxiv.org/bibtex/2508.16190' }
    let(:fixture) { File.read 'spec/fixtures/http/bibtex-2508.16190.bib' }

    context 'when arxiv responds with BibTeX' do
      before { stub_request(:get, url).to_return(status: 200, body: fixture) }

      it 'returns the upstream BibTeX body' do
        expect(described_class.new(metadata, client: client).fetch).to eq fixture
      end
    end

    context 'when arxiv returns a non-200' do
      before { stub_request(:get, url).to_return(status: 404, body: '') }

      it 'returns nil' do
        expect(described_class.new(metadata, client: client).fetch).to be_nil
      end
    end
  end

  describe '#to_s' do
    let(:client) { Arxiv::Downloader::Client.new(rate_limit: 0) }
    let(:url)    { 'https://arxiv.org/bibtex/2508.16190' }

    context 'when fetch succeeds' do
      let(:fixture) { File.read 'spec/fixtures/http/bibtex-2508.16190.bib' }

      before { stub_request(:get, url).to_return(status: 200, body: fixture) }

      it 'returns the fetched BibTeX' do
        expect(described_class.new(metadata, client: client).to_s).to eq fixture
      end
    end

    context 'when fetch fails' do
      before { stub_request(:get, url).to_return(status: 500, body: '') }

      it 'falls back to synthesized BibTeX' do
        result = described_class.new(metadata, client: client).to_s

        expect(result).to include '@misc{paval2025comicscene154,'
      end
    end

    context 'when no client is provided' do
      it 'returns synthesized BibTeX without making a request' do
        result = described_class.new(metadata).to_s

        expect(result).to include '@misc{paval2025comicscene154,'
        expect(WebMock).not_to have_requested :get, url
      end
    end
  end
end
