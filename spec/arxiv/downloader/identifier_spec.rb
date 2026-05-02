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

  it 'parses an abstract page URL' do
    identifier = described_class.new 'https://arxiv.org/abs/1512.03385'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to be_nil
  end

  it 'parses a versioned abstract page URL' do
    identifier = described_class.new 'https://arxiv.org/abs/1512.03385v2'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to eq 2
  end

  it 'parses a PDF URL' do
    identifier = described_class.new 'https://arxiv.org/pdf/1512.03385.pdf'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to be_nil
  end

  it 'parses a versioned PDF URL' do
    identifier = described_class.new 'https://arxiv.org/pdf/1512.03385v2.pdf'

    expect(identifier.id).to      eq '1512.03385'
    expect(identifier.version).to eq 2
  end

  it 'parses an HTML version URL' do
    identifier = described_class.new 'https://arxiv.org/html/2506.15442'

    expect(identifier.id).to      eq '2506.15442'
    expect(identifier.version).to be_nil
  end

  it 'parses a versioned HTML version URL' do
    identifier = described_class.new 'https://arxiv.org/html/2506.15442v1'

    expect(identifier.id).to      eq '2506.15442'
    expect(identifier.version).to eq 1
  end

  it 'parses a legacy arxiv ID' do
    identifier = described_class.new 'cs/0002001'

    expect(identifier.id).to      eq 'cs/0002001'
    expect(identifier.version).to be_nil
  end

  it 'parses a versioned legacy arxiv ID' do
    identifier = described_class.new 'cs/0002001v3'

    expect(identifier.id).to      eq 'cs/0002001'
    expect(identifier.version).to eq 3
  end

  it 'parses a hyphenated legacy archive ID' do
    identifier = described_class.new 'alg-geom/9708001'

    expect(identifier.id).to      eq 'alg-geom/9708001'
    expect(identifier.version).to be_nil
  end
end
