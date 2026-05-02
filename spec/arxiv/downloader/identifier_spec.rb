RSpec.describe Arxiv::Downloader::Identifier do
  describe '.new' do
    context 'when input valid' do
      subject(:parsed_input) { described_class.new input }

      # modern ID
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

      # pre-2015 ID
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

      # modern ID in arxiv: namespace
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

      # pre-2015 ID in arxiv: namespace
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

      # modern ID in HTTPS abstract URL
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

      # modern ID in HTTPS PDF URL
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

      # modern ID in HTTPS HTML URL
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

      # modern ID in HTTP abstract URL
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

      # modern ID in HTTP PDF URL
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

      # modern ID in HTTP HTML URL
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

      # with category and legacy ID path
      context 'with category and legacy ID' do
        context 'with no version' do
          let(:input) { 'cs/0002001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'cs/0002001v3' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to eq 3
          end
        end
      end

      # with hyphenated category and legacy ID path
      context 'with hyphenated category and legacy ID' do
        context 'with no version' do
          let(:input) { 'alg-geom/9708001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'alg-geom/9708001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'alg-geom/9708001v7' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'alg-geom/9708001'
            expect(parsed_input.version).to eq 7
          end
        end
      end

      # with category and subject and legacy ID path (2 uppercase letters)
      context 'with category name and legacy ID' do
        context 'with no version' do
          let(:input) { 'math.GT/0312088' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'math.GT/0312088'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'math.GT/0312088v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'math.GT/0312088'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      # with category and subject and legacy ID path (2 uppercase letters)
      context 'with category abbreviation and legacy ID' do
        context 'with no version' do
          let(:input) { 'cs.SE/0501001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs.SE/0501001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'cs.SE/0501001v8' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs.SE/0501001'
            expect(parsed_input.version).to eq 8
          end
        end
      end

      # legacy ID in abstract URL
      context 'with category name and legacy ID in abstract URL' do
        context 'with no version' do
          let(:input) { 'https://arxiv.org/abs/cs/0002001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'https://arxiv.org/abs/cs/0002001v3' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to eq 3
          end
        end
      end

      # legacy ID in PDF URL
      context 'with category name and legacy ID in PDF URL' do
        context 'with .pdf extension and no version' do
          let(:input) { 'http://arxiv.org/pdf/cs/0002001.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with .pdf extension and version' do
          let(:input) { 'http://arxiv.org/pdf/cs/0002001v3.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to eq 3
          end
        end

        context 'with no .pdf extension and no version' do
          let(:input) { 'http://arxiv.org/pdf/cs/0002001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with no .pdf extension and with version' do
          let(:input) { 'http://arxiv.org/pdf/cs/0002001v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      # with category and subject abbreviation (2 uppercase letters) and legacy ID path
      context 'with category name and subject abbreviation and legacy ID in abstract URL' do
        context 'with no version' do
          let(:input) { 'https://arxiv.org/abs/math.GT/0312088' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'math.GT/0312088'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'https://arxiv.org/abs/math.GT/0312088v4' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'math.GT/0312088'
            expect(parsed_input.version).to eq 4
          end
        end
      end

      # with category and subject abbreviation (2 uppercase letters) and legacy ID path
      context 'with category name and subject abbreviation and legacy ID in PDF URL' do
        context 'with .pdf extension and no version' do
          let(:input) { 'http://arxiv.org/pdf/pdf/math.GT/0312088.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'pdf/math.GT/0312088'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with .pdf extension and version' do
          let(:input) { 'http://arxiv.org/pdf/pdf/math.GT/0312088v3.pdf' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'pdf/math.GT/0312088'
            expect(parsed_input.version).to eq 3
          end
        end

        context 'with no .pdf extension and no version' do
          let(:input) { 'http://arxiv.org/pdf/pdf/math.GT/0312088' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'pdf/math.GT/0312088'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with no .pdf extension and with version' do
          let(:input) { 'http://arxiv.org/pdf/pdf/math.GT/0312088v9' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'pdf/math.GT/0312088'
            expect(parsed_input.version).to eq 9
          end
        end
      end

      # modern ID in arxiv: namespace
      context 'with namespaced with category and legacy ID path' do
        context 'with no version' do
          let(:input) { 'arxiv:cs/0002001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'arxiv:cs/0002001v2' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'cs/0002001'
            expect(parsed_input.version).to eq 2
          end
        end
      end

      # pre-2015 ID in arxiv: namespace
      context 'with hyphenated namespaced with category and legacy ID path' do
        context 'with no version' do
          let(:input) { 'arxiv:alg-geom/9708001' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'alg-geom/9708001'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with version' do
          let(:input) { 'arxiv:alg-geom/9708001v3' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq 'alg-geom/9708001'
            expect(parsed_input.version).to eq 3
          end
        end
      end

      # surrounding whitespace tolerance (delete_spaces!)
      context 'with surrounding whitespace' do
        context 'with leading space' do
          let(:input) { ' 2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with trailing space' do
          let(:input) { '2508.16190 ' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with leading and trailing space' do
          let(:input) { ' 2508.16190 ' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with trailing newline' do
          let(:input) { "2508.16190\n" }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with surrounding tabs' do
          let(:input) { "\t2508.16190\t" }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with multiple surrounding spaces' do
          let(:input) { '  2508.16190  ' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end
      end

      # trailing slash tolerance (strip_slashes!)
      context 'with trailing slash on URL' do
        context 'with single trailing slash' do
          let(:input) { 'https://arxiv.org/abs/2508.16190/' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with multiple trailing slashes' do
          let(:input) { 'https://arxiv.org/abs/2508.16190//' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end
      end

      # mixed-case arxiv: prefix tolerance (delete_arxiv_namespace! /i)
      context 'with mixed-case arxiv: prefix' do
        context 'with uppercase ARXIV:' do
          let(:input) { 'ARXIV:2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with camel case arXiv:' do
          let(:input) { 'arXiv:2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end

        context 'with capitalized Arxiv:' do
          let(:input) { 'Arxiv:2508.16190' }

          it 'parses ID and version' do
            expect(parsed_input.id).to      eq '2508.16190'
            expect(parsed_input.version).to be_nil
          end
        end
      end
    end

    context 'when input invalid' do
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
