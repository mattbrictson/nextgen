# frozen_string_literal: true

require_relative "test_case"

class Nextgen::Generators::RubocopTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination

  setup do
    %w[README.md Rakefile].each { FileUtils.touch Pathname.new(destination_root).join(_1) }
    Pathname.new(destination_root).join("Gemfile").write(<<~GEMFILE)
      source "https://rubygems.org"
    GEMFILE
  end

  test "adds rubocop gems in development group, with version spec for rubocop-rails" do
    apply_generator

    assert_file "Gemfile", /#{Regexp.quote(<<~GEMFILE)}/
      group :development do
        gem "rubocop", require: false
        gem "rubocop-performance", require: false
        gem "rubocop-rails", ">= 2.22.0", require: false
      end
    GEMFILE
  end

  test "generates a .rubocop.yml file that requires additional plugins" do
    apply_generator

    assert_file ".rubocop.yml", /#{Regexp.quote(<<~YML)}/
      require:
        - rubocop-performance
        - rubocop-rails
    YML
  end
end
