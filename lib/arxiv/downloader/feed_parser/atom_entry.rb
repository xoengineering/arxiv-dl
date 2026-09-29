module Arxiv
  module Downloader
    class FeedParser
      class AtomEntry < Feedjira::Parser::AtomEntry
        elements :author, as: :authors, class: AuthorElement

        element 'arxiv:primary_category', as: :primary_category_id, value: :term
        element 'arxiv:comment',          as: :comment
        element 'arxiv:doi',              as: :doi
        element 'arxiv:journal_ref',      as: :journal_ref
      end
    end
  end
end
