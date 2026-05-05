require 'tmpdir'

RSpec.describe Arxiv::Downloader::Metadata::Markdown do
  let(:metadata) do
    Arxiv::Downloader::Metadata.new(
      arxiv_id:         '2508.16190',
      arxiv_url:        'https://arxiv.org/abs/2508.16190',
      pdf_url:          'https://arxiv.org/pdf/2508.16190.pdf',
      title:            'ComicScene154: A Scene Dataset for Comic Analysis',
      authors:          ['Sandro Paval', 'Ivan P. Yamshchikov', 'Pascal Meißner'],
      abstract:         "Two lines\nof abstract.",
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
    it 'writes metadata.md into the target directory' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        expect(File).to exist File.join(dir, 'metadata.md')
      end
    end

    it 'opens with a YAML frontmatter block' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        body = File.read File.join(dir, 'metadata.md')
        expect(body).to start_with "---\n"
        expect(body).to include "\n---\n"
      end
    end

    it 'frontmatter contains all expected fields' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        body, frontmatter = parsed File.join(dir, 'metadata.md')
        expect(frontmatter.keys).to include(
          'arxiv_id', 'arxiv_url', 'pdf_url', 'title', 'authors',
          'published', 'updated', 'primary_category', 'categories',
          'comment', 'doi', 'journal_ref', 'bibtex_key', 'abstract'
        )
        expect(frontmatter['bibtex_key']).to eq 'paval2025comicscene154'
        expect(body).to include '# ComicScene154: A Scene Dataset for Comic Analysis'
      end
    end

    it 'body contains title heading, authors list, dates, links, abstract section' do
      Dir.mktmpdir do |dir|
        described_class.new(metadata).write to: dir

        body, = parsed File.join(dir, 'metadata.md')
        expect(body).to include '# ComicScene154: A Scene Dataset for Comic Analysis'
        expect(body).to include '- Sandro Paval'
        expect(body).to include '- Ivan P. Yamshchikov'
        expect(body).to include '- Pascal Meißner'
        expect(body).to include '2025-08-22'
        expect(body).to include 'cs.CL'
        expect(body).to include 'Computation and Language'
        expect(body).to include 'Computer Science'
        expect(body).to include '[2508.16190](https://arxiv.org/abs/2508.16190)'
        expect(body).to include '[PDF](https://arxiv.org/pdf/2508.16190.pdf)'
        expect(body).to include '## Abstract'
        expect(body).to include 'Two lines'
      end
    end
  end

  def parsed path
    text = File.read path
    _, frontmatter_text, body = text.split(/^---\n/, 3)
    [body, YAML.safe_load(frontmatter_text, permitted_classes: [Date])]
  end
end
