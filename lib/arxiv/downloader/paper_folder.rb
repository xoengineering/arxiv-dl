require 'nokogiri'

module Arxiv
  module Downloader
    # DL::Core::PaperFolder, plus fixing html/ links when a flat version moves into v<N>/
    class PaperFolder < DL::Core::PaperFolder
      # html/ moved one level deeper, so relative links up into _shared/ need one more ../
      def moved_into destination
        Dir.glob(File.join(destination, 'html', '*.html')).each do |html_path|
          document = Nokogiri::HTML File.read(html_path)
          HTMLArchive::ASSET_SELECTORS.each do |selector, attribute|
            document.css(selector).each do |node|
              node[attribute] = "../#{node[attribute]}" if node[attribute].start_with? '../'
            end
          end
          File.write html_path, document.to_html
        end
      end
    end
  end
end
