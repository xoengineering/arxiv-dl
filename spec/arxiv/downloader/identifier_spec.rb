RSpec.describe Arxiv::Downloader::Identifier do
  # cases = {
  #   # Modern, bare
  #   '2508.16190'                             => ['2508.16190',       nil],
  #   '2508.16190v2'                           => ['2508.16190',       2],
  #   '0706.0001'                              => ['0706.0001',        nil], # 4-digit sequence (pre-2015)
  #   '0706.0001v3'                            => ['0706.0001',        3],

  #   # Modern, arXiv: prefix
  #   'arXiv:2508.16190'                       => ['2508.16190',       nil],
  #   'arXiv:2508.16190v2'                     => ['2508.16190',       2],

  #   # Modern, https URLs
  #   'https://arxiv.org/abs/2508.16190'       => ['2508.16190',       nil],
  #   'https://arxiv.org/abs/2508.16190v2'     => ['2508.16190',       2],
  #   'https://arxiv.org/pdf/2508.16190.pdf'   => ['2508.16190',       nil],
  #   'https://arxiv.org/pdf/2508.16190v2.pdf' => ['2508.16190',       2],
  #   'https://arxiv.org/pdf/2508.16190'       => ['2508.16190',       nil], # no .pdf
  #   'https://arxiv.org/html/2506.15442'      => ['2506.15442',       nil],
  #   'https://arxiv.org/html/2506.15442v1'    => ['2506.15442',       1],

  #   # Modern, http URLs (non-https)
  #   'http://arxiv.org/abs/2508.16190'        => ['2508.16190',       nil],

  #   # Legacy, bare
  #   'cs/0002001'                             => ['cs/0002001',       nil],
  #   'cs/0002001v3'                           => ['cs/0002001',       3],
  #   'alg-geom/9708001'                       => ['alg-geom/9708001', nil],

  #   # Legacy with subject class (2 uppercase letters)
  #   'math.GT/0312088'                        => ['math.GT/0312088',  nil],
  #   'math.GT/0312088v2'                      => ['math.GT/0312088',  2],
  #   'cs.SE/0501001'                          => ['cs.SE/0501001',    nil],

  #   # Legacy in URL
  #   'https://arxiv.org/abs/cs/0002001'       => ['cs/0002001',       nil],
  #   'https://arxiv.org/abs/cs/0002001v3'     => ['cs/0002001',       3],
  #   'https://arxiv.org/pdf/cs/0002001.pdf'   => ['cs/0002001',       nil],
  #   'https://arxiv.org/abs/math.GT/0312088'  => ['math.GT/0312088',  nil],

  #   # Legacy with arXiv: prefix
  #   'arXiv:cs/0002001'                       => ['cs/0002001',       nil]
  # }

  # cases.each do |input, (expected_id, expected_version)|
  #   it "parses #{input.inspect}" do
  #     identifier = described_class.new input

  #     expect(identifier.id).to      eq expected_id
  #     expect(identifier.version).to eq expected_version
  #   end
  # end

  # invalid_inputs
  # 'arxiv.org/foo'

  describe '.new' do
    context 'with invalid input' do
      context 'with nil input' do
        let(:input) { nil }

        it 'raises Invalid error' do
          expect { described_class.new input }.to raise_error described_class::Invalid, 'blank input is invalid'
        end
      end

      context 'with blank string input' do
        let(:input) { '' }

        it 'raises Invalid error' do
          expect { described_class.new input }.to raise_error described_class::Invalid, 'blank input is invalid'
        end
      end

      context 'with non-arXiv URL input' do
        let(:input) { 'https://example.com/abs/2508.16190' }

        it 'raises Invalid error' do
          expect { described_class.new input }
            .to raise_error described_class::Invalid, 'domains other than arxiv.org are invalid'
        end
      end

      context 'with no dot or slash in string input' do
        let(:input) { 'garbage' }

        it 'raises Invalid error' do
          expect { described_class.new input }
            .to raise_error described_class::Invalid, "not a recognizable arXiv identifier: #{input}"
        end
      end

      context 'with no dot or slash in number input' do
        let(:input) { '12345' }

        it 'raises Invalid error' do
          expect { described_class.new input }
            .to raise_error described_class::Invalid, "not a recognizable arXiv identifier: #{input}"
        end
      end
    end
  end
end

# invalid_inputs.each do |input|
#   it "raises Invalid for #{input.inspect}" do
#     expect { described_class.new input }.to raise_error described_class::Invalid, /#{Regexp.escape(input)}/
#   end
# end
