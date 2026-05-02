module Arxiv
  module Downloader
    class Identifier
      class Invalid < Error; end

      attr_reader :id, :version, :input

      def initialize input
        @input = input
        @cleaned_input = input.dup

        validate_input
        set_id_and_version
      end

      private

      # validations

      def validate_input
        invalidate_nil_input
        invalidate_blank_input
        invalidate_wrong_domain_input
        invalidate_no_dot_no_slash_input
        invalidate_pathless_arxiv_url_input
        invalidate_apex_arxiv_url_input
        invalidate_incomplete_arxiv_url_input
      end

      def invalidate_nil_input
        raise Invalid, 'blank input is invalid' if @input.nil?
      end

      def invalidate_blank_input
        raise Invalid, 'blank input is invalid' if @input.empty?
      end

      def invalidate_wrong_domain_input
        invalid = true if @cleaned_input.include?('http') && !@cleaned_input.include?('arxiv.org')

        raise Invalid, 'domains other than arxiv.org are invalid' if invalid
      end

      def invalidate_no_dot_no_slash_input
        invalid = true if !@cleaned_input.include?('.') && !@cleaned_input.include?('/')

        raise Invalid, "not a recognizable arXiv identifier: #{input}" if invalid
      end

      def invalidate_pathless_arxiv_url_input
        invalid = true if @cleaned_input.split('arxiv.org/').last.nil?

        raise Invalid, "not a recognizable arXiv identifier URL: #{input}" if invalid
      end

      def invalidate_apex_arxiv_url_input
        invalid = true if @cleaned_input.split('arxiv.org').last.nil?

        raise Invalid, "not a recognizable arXiv identifier URL: #{input}" if invalid
      end

      def invalidate_incomplete_arxiv_url_input
        path = @cleaned_input.split('arxiv.org/').last
        invalid = true if !path.include?('.') && !path.include?('/')

        raise Invalid, "not a recognizable arXiv identifier URL: #{input}" if invalid
      end

      # setter

      def set_id_and_version
        normalize_input
        @id = @cleaned_input
      end

      # mutaters

      def normalize_input
        delete_spaces!
        strip_slashes!
        delete_protocols!
        delete_domain!
        delete_format_namespaces!
        delete_arxiv_namespace!
        delete_file_extensions!
        extract_version!
      end

      def delete_spaces!
        @cleaned_input.chomp!
        @cleaned_input.strip!
        @cleaned_input.squeeze! ' '
      end

      def strip_slashes!
        loop do
          @cleaned_input.delete_suffix! '/'
          break unless @cleaned_input.end_with? '/'
        end
      end

      def delete_protocols!
        @cleaned_input.delete_prefix! 'http://'
        @cleaned_input.delete_prefix! 'https://'
      end

      def delete_domain!
        @cleaned_input.sub! 'arxiv.org', ''
      end

      def delete_format_namespaces!
        %w[/abs/ /html/ /pdf/].each do |format_namespace|
          @cleaned_input.sub! format_namespace, ''
        end
      end

      def delete_arxiv_namespace!
        @cleaned_input.sub!(/(arxiv:)/i, '')
      end

      def delete_file_extensions!
        @cleaned_input.delete_suffix! '.pdf'
      end

      def extract_version!
        dot_parts   = @cleaned_input.split('.')
        slash_parts = dot_parts.last.split('/')
        v_parts     = slash_parts.last.split('v')

        @version    = Integer(v_parts.last) if v_parts.length > 1
        @cleaned_input.delete_suffix! "v#{@version}" unless @version.nil?
      end
    end
  end
end
