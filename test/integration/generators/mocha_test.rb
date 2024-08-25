# frozen_string_literal: true

require_relative "test_case"

class Nextgen::Generators::MochaTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination
  setup :empty_destination_gemfile

  test "installs mocha gem" do
    apply_generator

    assert_file "Gemfile", /#{Regexp.quote(<<~GEMFILE)}/
      group :test do
        gem "mocha"
      end
    GEMFILE
  end

  test "creates a test/support/mocha.rb file, assuming minitest is present" do
    Dir.chdir(destination_root) do
      FileUtils.mkdir_p("test")
      FileUtils.touch("test/test_helper.rb")
    end

    apply_generator
    assert_file "test/support/mocha.rb"
  end
end
