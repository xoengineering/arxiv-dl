module Arxiv
  module Downloader
    class FeedParser
      class Author
        include SAXMachine

        element  :name
        elements 'arxiv:affiliation', as: :affiliations
      end
    end
  end
end
