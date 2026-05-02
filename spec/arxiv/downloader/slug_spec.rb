RSpec.describe Arxiv::Downloader::Slug do
  it 'slugifies a plain title' do
    expect(described_class.new('Deep Residual Learning for Image Recognition').to_s)
      .to eq 'deep-residual-learning-for-image-recognition'
  end
end
