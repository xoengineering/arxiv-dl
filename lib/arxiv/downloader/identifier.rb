module Arxiv
  module Downloader
    class Identifier
      class Invalid < Error; end

      attr_reader :id, :version, :input

      def initialize input
        @input = input
        @draft = input.dup

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
      end

      def invalidate_nil_input
        raise Invalid, 'blank input is invalid' if @input.nil?
      end

      def invalidate_blank_input
        raise Invalid, 'blank input is invalid' if @input.empty?
      end

      def invalidate_wrong_domain_input
        invalid = true if @draft.include?('http') && !@draft.include?('arxiv.org')

        raise Invalid, 'domains other than arxiv.org are invalid' if invalid
      end

      def invalidate_no_dot_no_slash_input
        invalid = false
        invalid = true if !@draft.include?('.') && !@draft.include?('/')

        raise Invalid, "not a recognizable arXiv identifier: #{input}" if invalid
      end

      # setter

      def set_id_and_version
        normalize_input
        @id = @draft
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
        @draft.chomp!
        @draft.strip!
        @draft.squeeze! ' '
      end

      def strip_slashes!
        loop do
          @draft.delete_suffix! '/'
          break unless @draft.end_with? '/'
        end
      end

      def delete_protocols!
        @draft.delete_prefix! 'http://'
        @draft.delete_prefix! 'https://'
      end

      def delete_domain!
        @draft.sub! 'arxiv.org', ''
      end

      def delete_format_namespaces!
        %w[/abs/ /html/ /pdf/].each do |format_namespace|
          @draft.sub! format_namespace, ''
        end
      end

      def delete_arxiv_namespace!
        @draft.sub!(/(arxiv:)/i, '')
      end

      def delete_file_extensions!
        @draft.delete_suffix! '.pdf'
      end

      def extract_version!
        dot_parts   = @draft.split('.')
        slash_parts = dot_parts.last.split('/')
        v_parts     = slash_parts.last.split('v')

        @version    = Integer(v_parts.last) if v_parts.length > 1
        @draft.delete_suffix! "v#{@version}" unless @version.nil?
      end

      # URL_PREFIXES = %w[
      #   https://arxiv.org/abs/
      #   https://arxiv.org/pdf/
      #   https://arxiv.org/html/
      #   http://arxiv.org/abs/
      #   http://arxiv.org/pdf/
      #   http://arxiv.org/html/
      # ].freeze

      # ARXIV_PREFIX = 'arXiv:'.freeze
      # PDF_SUFFIX   = '.pdf'.freeze

      # attr_reader :id, :version

      # def initialize input
      #   rest = input
      #   rest = strip_url_prefix   rest
      #   rest = strip_pdf_suffix   rest
      #   rest = strip_arxiv_prefix rest

      #   @id, @version = split_version rest

      #   validate! original: input
      # end

      # private

      # def strip_url_prefix str
      #   match = URL_PREFIXES.find { |prefix| str.start_with? prefix }
      #   match ? str[match.length..] : str
      # end

      # def strip_pdf_suffix str
      #   return str unless str.end_with? PDF_SUFFIX

      #   str[0...-PDF_SUFFIX.length]
      # end

      # def strip_arxiv_prefix str
      #   return str unless str.downcase.start_with? ARXIV_PREFIX.downcase

      #   str[ARXIV_PREFIX.length..]
      # end

      # # Peel a trailing 'vN' off the end; N must be all digits.
      # def split_version str
      #   digits_start = str.length
      #   digits_start -= 1 while digits_start.positive? && digit?(str[digits_start - 1])

      #   return [str, nil] if digits_start == str.length         # no trailing digits
      #   return [str, nil] if digits_start.zero?                 # nothing before the digits
      #   return [str, nil] if str[digits_start - 1] != 'v'       # digits not preceded by 'v'

      #   [str[0...(digits_start - 1)], str[digits_start..].to_i]
      # end

      # def validate! original:
      #   return if modern_id?(@id) || legacy_id?(@id)

      #   raise Invalid, "not a recognizable arxiv identifier: #{original.inspect}"
      # end

      # # Modern arxiv ID shape: YYMM.NNNNN (4 digits, dot, 4-or-5 digits)
      # def modern_id? str
      #   year_month, sequence = str.split '.', 2

      #   return false if year_month.nil? || sequence.nil?
      #   return false unless year_month.length == 4
      #   return false unless sequence.length.between? 4, 5

      #   digits?(year_month) && digits?(sequence)
      # end

      # # Legacy arxiv ID shape: <archive>[.<2-uppercase-letter subject class>]/<7 digits>
      # # Examples: cs/0002001, alg-geom/9708001, math.GT/0312088, cs.SE/0501001
      # def legacy_id? str
      #   archive_part, sequence = str.split '/', 2

      #   return false if archive_part.nil? || sequence.nil?
      #   return false unless sequence.length == 7
      #   return false unless digits? sequence

      #   archive, subject_class = archive_part.split '.', 2

      #   return false if archive.nil? || archive.empty?
      #   return false unless ('a'..'z').cover? archive[0]
      #   return false unless archive.delete('a-z-').empty?
      #   return true if subject_class.nil?

      #   subject_class.length == 2 && subject_class.delete('A-Z').empty?
      # end

      # def digit? char
      #   ('0'..'9').cover? char
      # end

      # def digits? str
      #   !str.empty? && str.delete('0-9').empty?
      # end
    end
  end
end
