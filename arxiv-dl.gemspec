# frozen_string_literal: true

require_relative "lib/arxiv/downloader/version"

Gem::Specification.new do |spec|
  spec.name = "arxiv-dl"
  spec.version = Arxiv::Downloader::VERSION
  spec.authors = ["Shane Becker"]
  spec.email = ["veganstraightedge@gmail.com"]

  spec.summary = "Download papers and metadata from arxiv.org for offline archives."
  spec.description = "Command line tool and Ruby library for archiving arxiv.org papers as PDFs with sidecar metadata."
  spec.homepage = "https://github.com/veganstraightedge/arxiv-dl"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/veganstraightedge/arxiv-dl"
  spec.metadata["changelog_uri"] = "https://github.com/veganstraightedge/arxiv-dl/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
