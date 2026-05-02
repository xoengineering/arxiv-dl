RSpec.describe Arxiv::Downloader::FeedParser do
  let(:xml)      { File.read 'spec/fixtures/http/atom-2508.16190.xml' }
  let(:metadata) { described_class.new(xml).metadata }

  describe '#metadata' do
    it 'extracts the title' do
      expect(metadata.title).to eq 'ComicScene154: A Scene Dataset for Comic Analysis'
    end
  end
end
