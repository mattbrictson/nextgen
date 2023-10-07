require_relative "lib/nextgen/version"

Gem::Specification.new do |spec|
  spec.name = "nextgen"
  spec.version = Nextgen::VERSION
  spec.authors = ["Matt Brictson"]
  spec.email = ["opensource@mattbrictson.com"]

  spec.summary = "Generate your next Rails app interactively!"
  spec.homepage = "https://github.com/mattbrictson/nextgen"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/mattbrictson/nextgen/issues",
    "changelog_uri" => "https://github.com/mattbrictson/nextgen/releases",
    "source_code_uri" => "https://github.com/mattbrictson/nextgen",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "thor", "~> 1.2"
end
