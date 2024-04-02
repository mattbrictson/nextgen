gems = File.exist?("Gemfile") ? File.read("Gemfile").scan(/^\s*gem ["'](.+?)["']/).flatten : []
template ".github/workflows/ci.yml.tt", context: binding
copy_file ".github/dependabot.yml"
