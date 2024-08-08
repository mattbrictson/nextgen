# frozen_string_literal: true

require "test_helper"
require "tempfile"

class Nextgen::TidyGemfileTest < Minitest::Test
  def test_cleans_gemfile_by_removing_comments_and_maintaining_space_between_sections
    original = <<~GEMFILE
      source "https://rubygems.org"

      # Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
      gem "rails", "~> 7.2.0.rc1"
      # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
      gem "sprockets-rails"

      # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
      # gem "kredis"

      group :development, :test do
        # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
        gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

        # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
        gem "brakeman", require: false
      end

      group :development do
        # Use console on exceptions pages [https://github.com/rails/web-console]
        gem "web-console"
      end

      group :test do
        # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
        gem "capybara"
        gem "selenium-webdriver"
      end
    GEMFILE

    expected = <<~GEMFILE
      source "https://rubygems.org"

      gem "rails", "~> 7.2.0.rc1"
      gem "sprockets-rails"

      group :development, :test do
        gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
        gem "brakeman", require: false
      end

      group :development do
        gem "web-console"
      end

      group :test do
        gem "capybara"
        gem "selenium-webdriver"
      end
    GEMFILE

    Tempfile.create do |file|
      File.write(file.path, original)
      tidy = Nextgen::TidyGemfile.new(file.path)
      tidy.clean
      tidy.save

      assert_equal(expected, File.read(file.path))
    end
  end
end
