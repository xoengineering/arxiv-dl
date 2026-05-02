RSpec.describe Arxiv::Downloader::Identifier do
  it 'parses a bare modern arxiv ID' do
    identifier = described_class.new '1512.03385'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to be_nil
  end

  it 'parses a versioned bare modern arxiv ID' do
    identifier = described_class.new '1512.03385v2'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to eq 2
  end

  it 'parses a prefixed arxiv ID' do
    identifier = described_class.new 'arXiv:1512.03385'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to be_nil
  end

  it 'parses a prefixed and versioned arxiv ID' do
    identifier = described_class.new 'arXiv:1512.03385v2'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to eq 2
  end
end
