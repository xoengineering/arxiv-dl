module Arxiv
  module Downloader
    class Identifier
      class Invalid < Error; end

      URL_PREFIXES = %w[
        https://arxiv.org/abs/
        https://arxiv.org/pdf/
        https://arxiv.org/html/
        http://arxiv.org/abs/
        http://arxiv.org/pdf/
        http://arxiv.org/html/
      ].freeze

      ARXIV_PREFIX = 'arXiv:'.freeze
      PDF_SUFFIX   = '.pdf'.freeze

      attr_reader :id, :version

      def initialize input
        rest = input
        rest = strip_url_prefix   rest
        rest = strip_pdf_suffix   rest
        rest = strip_arxiv_prefix rest

        @id, @version = split_version rest

        validate! original: input
      end

      private

      def strip_url_prefix str
        match = URL_PREFIXES.find { |prefix| str.start_with? prefix }
        match ? str[match.length..] : str
      end

      def strip_pdf_suffix str
        return str unless str.end_with? PDF_SUFFIX

        str[0...-PDF_SUFFIX.length]
      end

      def strip_arxiv_prefix str
        return str unless str.downcase.start_with? ARXIV_PREFIX.downcase

        str[ARXIV_PREFIX.length..]
      end

      # Peel a trailing 'vN' off the end; N must be all digits.
      def split_version str
        digits_start = str.length
        digits_start -= 1 while digits_start.positive? && digit?(str[digits_start - 1])

        return [str, nil] if digits_start == str.length         # no trailing digits
        return [str, nil] if digits_start.zero?                 # nothing before the digits
        return [str, nil] if str[digits_start - 1] != 'v'       # digits not preceded by 'v'

        [str[0...(digits_start - 1)], str[digits_start..].to_i]
      end

      def validate! original:
        return if modern_id?(@id) || legacy_id?(@id)

        raise Invalid, "not a recognizable arxiv identifier: #{original.inspect}"
      end

      # Modern arxiv ID shape: YYMM.NNNNN (4 digits, dot, 4-or-5 digits)
      def modern_id? str
        year_month, sequence = str.split '.', 2

        return false if year_month.nil? || sequence.nil?
        return false unless year_month.length == 4
        return false unless sequence.length.between? 4, 5

        digits?(year_month) && digits?(sequence)
      end

      # Legacy arxiv ID shape: <archive>[.<2-uppercase-letter subject class>]/<7 digits>
      # Examples: cs/0002001, alg-geom/9708001, math.GT/0312088, cs.SE/0501001
      def legacy_id? str
        archive_part, sequence = str.split '/', 2

        return false if archive_part.nil? || sequence.nil?
        return false unless sequence.length == 7
        return false unless digits? sequence

        archive, subject_class = archive_part.split '.', 2

        return false if archive.nil? || archive.empty?
        return false unless ('a'..'z').cover? archive[0]
        return false unless archive.delete('a-z-').empty?
        return true if subject_class.nil?

        subject_class.length == 2 && subject_class.delete('A-Z').empty?
      end

      def digit? char
        ('0'..'9').cover? char
      end

      def digits? str
        !str.empty? && str.delete('0-9').empty?
      end
    end
  end
end
