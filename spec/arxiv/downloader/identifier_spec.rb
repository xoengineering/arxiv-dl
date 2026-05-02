RSpec.describe Arxiv::Downloader::Identifier do
  # cases = {
  #   # Modern, bare
  #   [x] '2508.16190'                             => ['2508.16190',       nil],
  #   [x] '2508.16190v2'                           => ['2508.16190',       2],
  #   [x] '0706.0001'                              => ['0706.0001',        nil], # 4-digit sequence (pre-2015)
  #   [x] '0706.0001v3'                            => ['0706.0001',        3],

  #   # Modern, arXiv: prefix
  #   [x] 'arXiv:2508.16190'                       => ['2508.16190',       nil],
  #   [x] 'arXiv:2508.16190v2'                     => ['2508.16190',       2],
  #   [x] 'arXiv:0706.0001'                        => ['0706.0001',        nil], # 4-digit sequence (pre-2015)
  #   [x] 'arXiv:0706.0001v3'                      => ['0706.0001',        3],

  #   # Modern, https URLs
  #   [x] 'https://arxiv.org/abs/2508.16190'       => ['2508.16190',       nil],
  #   [x] 'https://arxiv.org/abs/2508.16190v2'     => ['2508.16190',       2],
  #   [x] 'https://arxiv.org/pdf/2508.16190.pdf'   => ['2508.16190',       nil],
  #   [x] 'https://arxiv.org/pdf/2508.16190v2.pdf' => ['2508.16190',       2],
  #   [x] 'https://arxiv.org/pdf/2508.16190'       => ['2508.16190',       nil], # no .pdf
  #   [x] 'https://arxiv.org/html/2506.15442'      => ['2506.15442',       nil],
  #   [x] 'https://arxiv.org/html/2506.15442v1'    => ['2506.15442',       1],

  #   # Modern, http URLs (non-https)
  #   [x] 'http://arxiv.org/abs/2508.16190'       => ['2508.16190',       nil],
  #   [x] 'http://arxiv.org/abs/2508.16190v2'     => ['2508.16190',       2],
  #   [x] 'http://arxiv.org/pdf/2508.16190.pdf'   => ['2508.16190',       nil],
  #   [x] 'http://arxiv.org/pdf/2508.16190v2.pdf' => ['2508.16190',       2],
  #   [x] 'http://arxiv.org/pdf/2508.16190'       => ['2508.16190',       nil], # no .pdf
  #   [x] 'http://arxiv.org/html/2506.15442'      => ['2506.15442',       nil],
  #   [x] 'http://arxiv.org/html/2506.15442v1'    => ['2506.15442',       1],

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

  describe '.new' do
    context 'when valid input' do
      subject(:parsed_input) { described_class.new input }

      context 'with modern 4digit dot 5digit ID' do
        context 'with no version' do
          let(:input) { '2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { '2508.16190v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      context 'with pre-2015 4digit dot 4digit ID' do
        context 'with no version' do
          let(:input) { '0706.0001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '0706.0001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { '0706.0001v3' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '0706.0001'
            expect(parsed_input.version).to eq 3
          end
        end
      end

      context 'with namespaced modern 4digit dot 5digit ID, no version' do
        context 'with no version' do
          let(:input) { 'arxiv:2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'arxiv:2508.16190v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      context 'with namespaced pre-2015 4digit dot 4digit ID' do
        context 'with no version' do
          let(:input) { 'arxiv:0706.0001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '0706.0001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'arxiv:0706.0001v3' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '0706.0001'
            expect(parsed_input.version).to eq 3
          end
        end
      end

      context 'with modern 4digit dot 5digit ID in HTTPS abstract URL' do
        context 'with no version' do
          let(:input) { 'https://arxiv.org/abs/2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'https://arxiv.org/abs/2508.16190v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      context 'with modern 4digit dot 5digit ID in HTTPS PDF URL' do
        context 'with .pdf extension and no version' do
          let(:input) { 'https://arxiv.org/pdf/2508.16190.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with .pdf extension and version' do
          let(:input) { 'https://arxiv.org/pdf/2508.16190v2.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end

        context 'with no .pdf extension and no version' do
          let(:input) { 'https://arxiv.org/pdf/2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with no .pdf extension and with version' do
          let(:input) { 'https://arxiv.org/pdf/2508.16190v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      context 'with modern 4digit dot 5digit ID in HTTPS HTML URL' do
        context 'with no version' do
          let(:input) { 'https://arxiv.org/html/2506.15442' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2506.15442'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'https://arxiv.org/html/2506.15442v1' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2506.15442'
            expect(parsed_input.version).to eq 1
          end
        end
      end

      context 'with modern 4digit dot 5digit ID in HTTP (no S) abstract URL' do
        context 'with no version' do
          let(:input) { 'http://arxiv.org/abs/2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'http://arxiv.org/abs/2508.16190v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      context 'with modern 4digit dot 5digit ID in HTTP (no S) PDF URL' do
        context 'with .pdf extension and no version' do
          let(:input) { 'http://arxiv.org/pdf/2508.16190.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with .pdf extension and version' do
          let(:input) { 'http://arxiv.org/pdf/2508.16190v2.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end

        context 'with no .pdf extension and no version' do
          let(:input) { 'http://arxiv.org/pdf/2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with no .pdf extension and with version' do
          let(:input) { 'http://arxiv.org/pdf/2508.16190v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      context 'with modern 4digit dot 5digit ID in HTTP (no S) HTML URL' do
        context 'with no version' do
          let(:input) { 'http://arxiv.org/html/2506.15442' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2506.15442'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'http://arxiv.org/html/2506.15442v1' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2506.15442'
            expect(parsed_input.version).to eq 1
          end
        end
      end
    end

    context 'when invalid input' do
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

      context 'with pathless arXiv URL input' do
        let(:input) { 'arxiv.org' }

        it 'raises Invalid error' do
          expect { described_class.new input }
            .to raise_error described_class::Invalid, "not a recognizable arXiv identifier URL: #{input}"
        end
      end

      context 'with pathless arXiv URL with trailing slash input' do
        let(:input) { 'arxiv.org/' }

        it 'raises Invalid error' do
          expect { described_class.new input }
            .to raise_error described_class::Invalid, "not a recognizable arXiv identifier URL: #{input}"
        end
      end

      context 'with incomplete arXiv URL input' do
        let(:input) { 'arxiv.org/foo' }

        it 'raises Invalid error' do
          expect { described_class.new input }
            .to raise_error described_class::Invalid, "not a recognizable arXiv identifier URL: #{input}"
        end
      end
    end
  end
end
