RSpec.describe Arxiv::Downloader::Identifier do
  cases = {
    '2508.16190'                             => ['2508.16190',       nil],
    '2508.16190v2'                           => ['2508.16190',       2],
    'arXiv:2508.16190'                       => ['2508.16190',       nil],
    'arXiv:2508.16190v2'                     => ['2508.16190',       2],
    'https://arxiv.org/abs/2508.16190'       => ['2508.16190',       nil],
    'https://arxiv.org/abs/2508.16190v2'     => ['2508.16190',       2],
    'https://arxiv.org/pdf/2508.16190.pdf'   => ['2508.16190',       nil],
    'https://arxiv.org/pdf/2508.16190v2.pdf' => ['2508.16190',       2],
    'https://arxiv.org/html/2506.15442'      => ['2506.15442',       nil],
    'https://arxiv.org/html/2506.15442v1'    => ['2506.15442',       1],
    'cs/0002001'                             => ['cs/0002001',       nil],
    'cs/0002001v3'                           => ['cs/0002001',       3],
    'alg-geom/9708001'                       => ['alg-geom/9708001', nil]
  }

  cases.each do |input, (expected_id, expected_version)|
    it "parses #{input.inspect}" do
      identifier = described_class.new input

      expect(identifier.id).to      eq expected_id
      expect(identifier.version).to eq expected_version
    end
  end

  invalid_inputs = [
    '',
    'garbage',
    '12345',
    'arxiv.org/foo',
    'https://example.com/abs/2508.16190'
  ]

  invalid_inputs.each do |input|
    it "raises Invalid for #{input.inspect}" do
      expect { described_class.new input }.to raise_error described_class::Invalid, /#{Regexp.escape(input)}/
    end
  end
end
