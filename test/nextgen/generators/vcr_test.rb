require_relative "test_case"

class Nextgen::Generators::VcrTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination

  setup do
    Pathname.new(destination_root).join("Gemfile").write(<<~GEMFILE)
      source "https://rubygems.org"
    GEMFILE
  end

  test "installs vcr and webmock gems" do
    apply_generator

    assert_file "Gemfile" do |gemfile|
      assert_match(/gem "vcr"/, gemfile)
      assert_match(/gem "webmock"/, gemfile)
    end
  end

  test "adds a test/support/vcr.rb file" do
    apply_generator

    assert_file "test/support/vcr.rb" do |support|
      refute_match(/rspec/, support)
    end
  end

  test "when rspec is present, adds a spec/support/vcr.rb file" do
    Dir.chdir(destination_root) do
      FileUtils.mkdir_p("spec/support")
      FileUtils.touch("spec/spec_helper.rb")
    end

    apply_generator

    assert_file "spec/support/vcr.rb" do |support|
      assert_match(/rspec/, support)
    end
  end
end
