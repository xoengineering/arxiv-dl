require 'tmpdir'

RSpec.describe Arxiv::Downloader::Metadata::Bibtex do
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
    it 'writes metadata.bib into the target directory' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        expect(File).to exist File.join(dir, 'metadata.bib')
      end
    end

    it 'writes synthesized BibTeX when no client is provided' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        body = File.read File.join(dir, 'metadata.bib')
        expect(body).to include '@misc{paval2025comicscene154,'
        expect(body).to include 'eprint={2508.16190}'
      end
    end

    it 'writes upstream BibTeX when fetch succeeds' do
      client  = Arxiv::Downloader::Client.new rate_limit: 0
      fixture = File.read 'spec/fixtures/http/bibtex-2508.16190.bib'
      stub_request(:get, 'https://arxiv.org/bibtex/2508.16190').to_return(status: 200, body: fixture)

      Dir.mktmpdir do |dir|
        described_class.new(metadata, client: client).write to: dir

        expect(File.read(File.join(dir, 'metadata.bib'))).to eq fixture
      end
    end
  end
end
