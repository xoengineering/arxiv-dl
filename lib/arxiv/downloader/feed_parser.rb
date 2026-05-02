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
        @feed = Feedjira.parse xml
      end

      def metadata
        entry    = @feed.entries.first
        arxiv_id = Identifier.new(entry.entry_id).id

        Metadata.new(
          arxiv_id:  arxiv_id,
          arxiv_url: "https://arxiv.org/abs/#{arxiv_id}",
          pdf_url:   "https://arxiv.org/pdf/#{arxiv_id}.pdf",
          title:     entry.title,
          authors:   entry.authors.map(&:name),
          abstract:  entry.summary.strip,
          published: entry.published.to_date,
          updated:   entry.updated.to_date
        )
      end
    end
  end
end
