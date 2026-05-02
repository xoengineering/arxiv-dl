RSpec.describe Arxiv::Downloader::Slug do
  it 'slugifies a plain title' do
    expect(described_class.new('Deep Residual Learning for Image Recognition').to_s)
      .to eq 'deep-residual-learning-for-image-recognition'
  end

  it 'truncates a long title to 80 chars at a word boundary' do
    title = 'Deep Residual Learning for Image Recognition with Convolutional Neural Networks Applied to Medical Diagnosis'
    slug  = described_class.new(title).to_s

    expect(slug.length).to be <= 80
    expect(slug).not_to    end_with '-'
    expect(slug).to        eq 'deep-residual-learning-for-image-recognition-with-convolutional-neural-networks'
  end
end
