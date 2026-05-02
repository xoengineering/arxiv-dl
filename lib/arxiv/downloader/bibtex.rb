module Arxiv
  module Downloader
    class Bibtex
      def initialize metadata, client: nil
        @metadata = metadata
        @client   = client
      end

      def synthesize
        <<~BIBTEX
          @misc{#{key},
            title={#{@metadata.title}},
            author={#{authors}},
            year={#{@metadata.published.year}},
            eprint={#{@metadata.arxiv_id}},
            archivePrefix={arXiv},
            primaryClass={#{@metadata.primary_category[:id]}},
            url={#{@metadata.arxiv_url}},
          }
        BIBTEX
      end

      def fetch
        return nil if @client.nil?

        response = @client.get url
        return nil unless response.status.success?

        response.to_s
      end

      def to_s
        fetch || synthesize
      end

      private

      def url
        "https://arxiv.org/bibtex/#{@metadata.arxiv_id}"
      end

      def key
        last_name  = @metadata.authors.first.split.last.downcase.gsub(/[^a-z]/, '')
        year       = @metadata.published.year
        title_word = Slug.new(@metadata.title).to_s.split('-').first

        "#{last_name}#{year}#{title_word}"
      end

      def authors
        @metadata.authors.join ' and '
      end
    end
  end
end
