require 'optparse'

module Arxiv
  module Downloader
    class CLI
      DEFAULT_DOWNLOAD_PATH = File.join Dir.home, 'Downloads', 'ArXiv_Papers'
      USAGE                 = 'Usage: arxiv-dl [options] <ARXIV_ID_OR_URL> [<ARXIV_ID_OR_URL>...]'.freeze

      def initialize argv, stderr: $stderr, stdin: $stdin, stdout: $stdout
        @argv   = argv
        @stderr = stderr
        @stdin  = stdin
        @stdout = stdout
      end

      def run
        options = parse
        return options.fetch(:exit_status) if options.key? :exit_status

        return error_with USAGE       if options[:targets].empty?
        return error_with conflict if options[:verbose] && options[:quiet]

        failures = download_each options
        failures.zero? ? 0 : 1
      end

      private

      def conflict
        '-v and -q are mutually exclusive'
      end

      def parse
        options = { targets: [], verbose: false, quiet: false }
        parser  = build_parser options

        begin
          parser.parse! @argv
          options[:targets] = @argv + input_targets(options[:input])
        rescue OptionParser::ParseError, SystemCallError => e
          @stderr.puts e.message
          return { exit_status: 1 }
        end

        options[:path]       ||= ENV['ARXIV_DOWNLOAD_PATH'] || DEFAULT_DOWNLOAD_PATH
        options[:rate_limit] ||= (ENV['ARXIV_RATE_LIMIT'] || Client::DEFAULT_RATE_LIMIT).to_i
        options
      end

      def build_parser options
        OptionParser.new do |parser|
          parser.banner = USAGE
          parser.on('-i FILE', '--input FILE')       { |value| options[:input] = value }
          parser.on('-p PATH', '--path PATH')        { |value| options[:path] = value }
          parser.on('--rate-limit SECONDS', Integer) { |value| options[:rate_limit] = value }
          parser.on('-v', '--verbose')               { options[:verbose] = true }
          parser.on('-q', '--quiet')                 { options[:quiet]   = true }
          parser.on('--version') do
            @stdout.puts VERSION
            options[:exit_status] = 0
          end
          parser.on('-h', '--help') do
            @stdout.puts parser.help
            options[:exit_status] = 0
          end
        end
      end

      # one target per line from FILE, or stdin for "-"; blank lines and # comments skipped
      def input_targets input
        return [] if input.nil?

        text = input == '-' ? @stdin.read : File.read(input)
        text.lines.map(&:strip).reject { it.empty? || it.start_with?('#') }
      end

      def error_with message
        @stderr.puts message
        1
      end

      def download_each options
        client = Client.new rate_limit: options[:rate_limit], log: (options[:verbose] ? @stdout : nil)

        failures = 0
        options[:targets].each do |target|
          failures += 1 unless download_one(target, client:, options:)
        end
        failures
      end

      # true on success; reports the failure and returns false otherwise
      def download_one target, client:, options:
        identifier = Identifier.new target
        @stdout.puts "==> Downloading #{identifier.id}" if options[:verbose]

        path = Archive.new(identifier, root: options[:path], client: client).run
        @stdout.puts path unless options[:quiet]
        true
      rescue Error, HTTP::Error => e
        @stderr.puts "#{target}: #{e.message}"
        false
      end
    end
  end
end
