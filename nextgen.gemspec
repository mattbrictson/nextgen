# frozen_string_literal: true

require_relative "lib/nextgen/version"

Gem::Specification.new do |spec|
  spec.name = "nextgen"
  spec.version = Nextgen::VERSION
  spec.authors = ["Matt Brictson"]
  spec.email = ["opensource@mattbrictson.com"]

  spec.summary = "Generate your next Rails app interactively!"
  spec.description = "Nextgen is an interactive and flexible alternative to `rails new` " \
                     "that includes opt-in support for modern frontend development with Vite."
  spec.homepage = "https://github.com/mattbrictson/nextgen"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/mattbrictson/nextgen/issues",
    "changelog_uri" => "https://github.com/mattbrictson/nextgen/releases",
    "source_code_uri" => "https://github.com/mattbrictson/nextgen",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(
    %w[
      LICENSE.txt
      README.md
      {config,exe,lib,template}/**/*
    ],
    File::FNM_DOTMATCH
  ).reject { |f| File.directory?(f) || f.end_with?(".DS_Store") }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", "~> 7.1.1"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "tty-prompt", "~> 0.23.1"
  spec.add_dependency "tty-screen", "~> 0.8.1"
  spec.add_dependency "zeitwerk", "~> 2.6"
end
