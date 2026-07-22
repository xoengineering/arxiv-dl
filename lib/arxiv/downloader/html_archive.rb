require 'fileutils'
require 'nokogiri'
require 'uri'

module Arxiv
  module Downloader
    class HTMLArchive
      ASSET_SELECTORS = {
        'img[src]'               => 'src',
        'script[src]'            => 'src',
        'link[rel="stylesheet"]' => 'href'
      }.freeze

      def initialize identifier, client:, assets_cache:
        @identifier   = identifier
        @client       = client
        @assets_cache = assets_cache
      end

      def download to:
        FileUtils.mkdir_p to

        document = Nokogiri::HTML @client.get(html_url).to_s
        ASSET_SELECTORS.each do |selector, attribute|
          document.css(selector).each { |node| process node, attribute, to }
        end

        File.write File.join(to, "#{@identifier.id}.html"), document.to_html
      end

      private

      def html_url
        "https://arxiv.org/html/#{@identifier.id}"
      end

      def process node, attribute, html_dir
        reference = node[attribute]
        return if reference.nil? || reference.empty?

        case reference_type(reference)
        when :page_relative then download_relative reference, html_dir
        when :remote        then cache_remote node, attribute, reference, html_dir
        when :root_relative then cache_remote node, attribute, "https://arxiv.org#{reference}", html_dir
        end
      end

      # :skip covers refs that can't or shouldn't be fetched: data:/javascript:/
      # mailto: URIs, protocol-relative refs, and malformed URIs. They are left
      # in the HTML untouched.
      def reference_type reference
        uri = URI.parse reference
        return :remote if %w[http https].include? uri.scheme
        return :skip unless uri.scheme.nil? && uri.host.nil?
        return :root_relative if reference.start_with? '/'

        :page_relative
      rescue URI::InvalidURIError
        :skip
      end

      def download_relative reference, html_dir
        File.binwrite File.join(html_dir, reference), @client.get(absolute_for(reference)).to_s
      end

      def absolute_for reference
        "https://arxiv.org/html/#{@identifier.id}/#{reference}"
      end

      def cache_remote node, attribute, reference, html_dir
        cached_path  = @assets_cache.fetch reference
        relative_ref = Pathname.new(cached_path).relative_path_from(Pathname.new(html_dir)).to_s
        node[attribute] = relative_ref
      end
    end
  end
end
