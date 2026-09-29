module Arxiv
  module Downloader
    class FeedParser
      class AtomFeed
        include SAXMachine
        include Feedjira::FeedUtilities

        elements :entry, as: :entries, class: AtomEntry

        def self.able_to_parse? xml
          xml.include? 'http://www.w3.org/2005/Atom'
        end
      end
    end
  end
end
