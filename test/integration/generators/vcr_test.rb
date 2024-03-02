require_relative "test_case"

class Nextgen::Generators::VcrTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination
  setup :empty_destination_gemfile

  test "installs vcr and webmock gems" do
    apply_generator

    assert_file "Gemfile", /#{Regexp.quote(<<~GEMFILE)}/
      group :test do
        gem "webmock"
        gem "vcr"
      end
    GEMFILE
  end

  test "when minitest is present, adds vcr and webmock test support files" do
    Dir.chdir(destination_root) do
      FileUtils.mkdir_p("test")
      FileUtils.touch("test/test_helper.rb")
      FileUtils.touch(".gitattributes")
    end

    apply_generator

    assert_file ".gitattributes" do |attrs|
      assert_match("test/cassettes/* linguist-generated", attrs)
    end

    assert_file "test/support/vcr.rb" do |support|
      refute_match(/rspec/, support)
    end

    assert_file "test/support/webmock.rb" do |support|
      assert_match('require "webmock/minitest"', support)
    end
  end

  test "when rspec is present, adds vcr and webmock spec support files" do
    Dir.chdir(destination_root) do
      FileUtils.mkdir_p("spec/support")
      FileUtils.touch("spec/spec_helper.rb")
      FileUtils.touch(".gitattributes")
    end

    apply_generator

    assert_file ".gitattributes" do |attrs|
      assert_match("spec/cassettes/* linguist-generated", attrs)
    end

    assert_file "spec/support/vcr.rb" do |support|
      assert_match(/rspec/, support)
    end

    assert_file "spec/support/webmock.rb" do |support|
      assert_match('require "webmock/rspec"', support)
    end
  end
end
