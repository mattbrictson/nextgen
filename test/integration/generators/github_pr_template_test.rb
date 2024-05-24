# frozen_string_literal: true

require_relative "test_case"

class Nextgen::Generators::GithubPrTemplateTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination

  test "creates a .github/PULL_REQUEST_TEMPLATE.md file" do
    apply_generator
    assert_file ".github/PULL_REQUEST_TEMPLATE.md"
  end
end
