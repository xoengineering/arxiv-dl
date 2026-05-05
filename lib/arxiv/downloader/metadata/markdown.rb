require 'fileutils'
require 'yaml'

module Arxiv
  module Downloader
    class Metadata
      class Markdown
        FILENAME = 'metadata.md'.freeze

        def initialize metadata
          @metadata = metadata
        end

        def write to:
          FileUtils.mkdir_p to
          File.write File.join(to, FILENAME), "#{frontmatter}\n#{body}"
        end

        private

        def frontmatter
          "---\n#{::YAML.dump(stringify(frontmatter_hash)).delete_prefix("---\n")}---"
        end

        def frontmatter_hash
          @metadata.to_h.merge bibtex_key: bibtex_key
        end

        def bibtex_key
          Downloader::Bibtex.new(@metadata).key
        end

        def stringify object
          case object
          when Hash  then object.to_h { |key, value| [key.to_s, stringify(value)] }
          when Array then object.map { |item| stringify item }
          else object
          end
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
          @metadata.authors.map { |author| "- #{author}" }.join "\n"
        end
      end
    end
  end
end
