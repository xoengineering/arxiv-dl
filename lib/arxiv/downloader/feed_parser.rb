require 'feedjira'

module Arxiv
  module Downloader
    class FeedParser
      class Author
        include SAXMachine

        element :name
      end

      class AtomEntry < Feedjira::Parser::AtomEntry
        elements :author, as: :authors, class: Author

        element 'arxiv:primary_category', as: :primary_category_id, value: :term
        element 'arxiv:comment',          as: :comment
        element 'arxiv:doi',              as: :doi
        element 'arxiv:journal_ref',      as: :journal_ref
      end

      class AtomFeed
        include SAXMachine
        include Feedjira::FeedUtilities

        elements :entry, as: :entries, class: AtomEntry

        def self.able_to_parse? xml
          xml.include? 'http://www.w3.org/2005/Atom'
        end
      end

      Feedjira.configure { |config| config.parsers = [AtomFeed] + config.parsers }

      def initialize xml
        @feed       = Feedjira.parse xml
        @categories = Categories.new
      end

      def metadata
        entry    = @feed.entries.first
        arxiv_id = Identifier.new(entry.entry_id).id

        Metadata.new(
          arxiv_id:         arxiv_id,
          arxiv_url:        "https://arxiv.org/abs/#{arxiv_id}",
          pdf_url:          "https://arxiv.org/pdf/#{arxiv_id}.pdf",
          title:            entry.title,
          authors:          entry.authors.map(&:name),
          abstract:         entry.summary.strip,
          published:        entry.published.to_date,
          updated:          entry.updated.to_date,
          primary_category: @categories.lookup(entry.primary_category_id),
          categories:       entry.categories.map { |id| @categories.lookup id },
          comment:          entry.comment,
          doi:              entry.doi,
          journal_ref:      entry.journal_ref
        )
      end
    end
  end
end
