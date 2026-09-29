require 'feedjira'                            # before all: SAXMachine, Feedjira::Parser::AtomEntry
require_relative 'feed_parser/author_element' # before atom_entry: AtomEntry uses class: AuthorElement
require_relative 'feed_parser/atom_entry'     # before atom_feed: AtomFeed uses class: AtomEntry
require_relative 'feed_parser/atom_feed'      # after atom_entry

module Arxiv
  module Downloader
    class FeedParser
      Feedjira.configure { |config| config.parsers = [AtomFeed] + config.parsers }

      def initialize xml
        @feed       = Feedjira.parse xml
        @categories = Categories.new
      end

      def metadata
        entry = @feed.entries.first
        raise PaperNotFound if entry.nil?

        arxiv_id = Identifier.new(entry.entry_id).id

        Metadata.new(
          arxiv_id:         arxiv_id,
          arxiv_url:        "https://arxiv.org/abs/#{arxiv_id}",
          pdf_url:          "https://arxiv.org/pdf/#{arxiv_id}.pdf",
          title:            entry.title,
          authors:          authors_of(entry),
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

      private

      def authors_of entry
        entry.authors.map do |author|
          Author.new name: author.name, affiliations: author.affiliations
        end
      end
    end
  end
end
