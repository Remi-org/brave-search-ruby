# frozen_string_literal: true

require_relative "lib/brave_search/version"

Gem::Specification.new do |spec|
  spec.name = "brave_search"
  spec.version = BraveSearch::VERSION
  spec.authors = ["Remi"]
  spec.email = ["remi@example.com"]

  spec.summary = "Ruby client for Brave Search API"
  spec.description = "Simple Ruby client for Brave Search API with Rails integration"
  spec.homepage = "https://github.com/example/brave-search-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z 2>/dev/null`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "async", "~> 2.0"
  spec.add_dependency "caxlsx", "~> 4.0"
  spec.add_dependency "concurrent-ruby", "~> 1.2"
  spec.add_dependency "httparty", "~> 0.21"

  spec.add_development_dependency "rails", "~> 8.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-rspec", "~> 2.20"
  spec.add_development_dependency "webmock", "~> 3.18"
end
