# frozen_string_literal: true

require_relative "test_case"

class Nextgen::Generators::RspecSystemTestingTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination

  setup do
    empty_destination_gemfile
    touch_destination_paths(%w[config/application.rb spec/spec_helper.rb])
  end

  test "installs capybara and selenium gems" do
    apply_generator

    assert_file "Gemfile", /#{Regexp.quote(<<~GEMFILE)}/
      group :test do
        gem "selenium-webdriver", require: false
        gem "capybara", require: false
      end
    GEMFILE
  end

  test "configures capybara and system specs" do
    apply_generator

    assert_file "spec/support/capybara.rb", %r{require "capybara/rspec"\n}
    assert_file "spec/support/capybara.rb", /Capybara\.configure/

    assert_file "spec/support/system.rb", /driven_by :selenium/
  end
end
