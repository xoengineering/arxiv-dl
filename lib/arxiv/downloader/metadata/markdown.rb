module Arxiv
  module Downloader
    class Metadata
      # metadata.md: dl-core writes the frontmatter; the body is arxiv-specific
      class Markdown
        def initialize metadata
          @metadata = metadata
        end

        def write to:
          DL::Core::Sidecar::Markdown.new(@metadata, body:, extras: { bibtex_key: }).write to:
        end

        private

        def bibtex_key
          Downloader::Bibtex.new(@metadata).key
        end

        def body
          <<~MARKDOWN

            # #{@metadata.title}

            #{authors_list}

            - Published: #{@metadata.published.iso8601}
            - Primary category: #{@metadata.primary_category[:id]} — #{@metadata.primary_category[:name]} (#{@metadata.primary_category[:group]})
            - arXiv: [#{@metadata.arxiv_id}](#{@metadata.arxiv_url})
            - [PDF](#{@metadata.pdf_url})

            ## Abstract

            #{@metadata.abstract}
          MARKDOWN
        end

        def authors_list
          @metadata.authors.map { |author| "- #{author_line author}" }.join "\n"
        end

        def author_line author
          return author.name if author.affiliations.empty?

          "#{author.name} (#{author.affiliations.join '; '})"
        end
      end
    end
  end
end
