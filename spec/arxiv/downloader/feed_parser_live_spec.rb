# Opt-in drift check against the real arxiv API: `ARXIV_LIVE=1 script/test`.
# Fetches each paper that has a recorded Atom fixture and expects it to parse
# into the same Metadata as the fixture. A failure means arxiv's API output
# changed (or a new paper version was posted) and the fixture needs re-recording.
RSpec.describe Arxiv::Downloader::FeedParser, :live do
  around do |example|
    WebMock.allow_net_connect!
    example.run
  ensure
    WebMock.disable_net_connect! allow_localhost: true
  end

  let(:client) { Arxiv::Downloader::Client.new }

  it 'parses the live arxiv API the same as each recorded Atom fixture' do
    aggregate_failures do
      Dir.glob('spec/fixtures/http/atom-*.xml').each do |path|
        arxiv_id = File.basename(path, '.xml').delete_prefix('atom-')
        atom_url = "https://export.arxiv.org/api/query?id_list=#{arxiv_id}"
        response = client.get atom_url

        expect(response.status).to be_success, "#{arxiv_id}: arxiv API returned #{response.status}"
        next unless response.status.success?

        live     = described_class.new(response.to_s).metadata
        recorded = described_class.new(File.read(path)).metadata

        expect(live).to eq(recorded), "#{arxiv_id} drifted from #{path}"
      end
    end
  end
end
