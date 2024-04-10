require_relative "test_case"

class Nextgen::Generators::GithubActionsTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination

  test "creates a .github/workflows/ci.yml file that has no Lint, Test, or Security jobs by default" do
    apply_generator
    assert_file ".github/workflows/ci.yml" do |ci|
      refute_match(/Lint/, ci)
      refute_match(/Test/, ci)
      refute_match(/RSpec/, ci)
      refute_match(/Security/, ci)
    end
  end

  test "includes an eslint job if in eslintrc file is present" do
    FileUtils.touch File.join(destination_root, "eslint.config.js")
    apply_generator
    assert_file ".github/workflows/ci.yml", %r{Lint / eslint}
  end

  test "includes a rubocop job if a Gemfile with rubocop is present" do
    File.write File.join(destination_root, "Gemfile"), 'gem "rubocop"\n'
    apply_generator
    assert_file ".github/workflows/ci.yml", %r{Lint / rubocop}
  end

  test "configures dependabot" do
    apply_generator
    assert_file ".github/dependabot.yml", /package-ecosystem: github-actions/
  end
end
