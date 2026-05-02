RSpec.describe Arxiv::Downloader::Identifier do
  cases = {
    '1512.03385'                             => ['1512.03385',       nil],
    '1512.03385v2'                           => ['1512.03385',       2],
    'arXiv:1512.03385'                       => ['1512.03385',       nil],
    'arXiv:1512.03385v2'                     => ['1512.03385',       2],
    'https://arxiv.org/abs/1512.03385'       => ['1512.03385',       nil],
    'https://arxiv.org/abs/1512.03385v2'     => ['1512.03385',       2],
    'https://arxiv.org/pdf/1512.03385.pdf'   => ['1512.03385',       nil],
    'https://arxiv.org/pdf/1512.03385v2.pdf' => ['1512.03385',       2],
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
end
