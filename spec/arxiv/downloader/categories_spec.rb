RSpec.describe Arxiv::Downloader::Categories do
  describe '#lookup' do
    subject(:result) { described_class.new.lookup id }

    context 'with a known modern category (cs.CL)' do
      let(:id) { 'cs.CL' }

      it 'returns id, name, and group' do
        expect(result[:id]).to    eq 'cs.CL'
        expect(result[:name]).to  eq 'Computation and Language'
        expect(result[:group]).to eq 'Computer Science'
      end
    end

    context 'with a known modern category (cs.CV)' do
      let(:id) { 'cs.CV' }

      it 'returns id, name, and group' do
        expect(result[:id]).to    eq 'cs.CV'
        expect(result[:name]).to  eq 'Computer Vision and Pattern Recognition'
        expect(result[:group]).to eq 'Computer Science'
      end
    end

    context 'with a hyphenated category id (cond-mat.dis-nn)' do
      let(:id) { 'cond-mat.dis-nn' }

      it 'returns id, name, and group' do
        expect(result[:id]).to    eq 'cond-mat.dis-nn'
        expect(result[:name]).to  eq 'Disordered Systems and Neural Networks'
        expect(result[:group]).to eq 'Physics'
      end
    end

    context 'with a bare-archive category (hep-th)' do
      let(:id) { 'hep-th' }

      it 'returns id, name, and group' do
        expect(result[:id]).to    eq 'hep-th'
        expect(result[:name]).to  eq 'High Energy Physics - Theory'
        expect(result[:group]).to eq 'Physics'
      end
    end

    context 'with an unknown category' do
      let(:id) { 'foo.BAR' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
