#!/usr/bin/env ruby

require "bundler/inline"
require "fileutils"
require "io/console"
require "open3"
require "shellwords"

def main # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  assert_git_repo!
  git_meta = read_git_data

  gem_name = ask("Gem name?", default: git_meta[:origin_repo_name])
  gem_summary = ask("Gem summary (< 60 chars)?", default: "")
  author_email = ask("Author email?", default: git_meta[:user_email])
  author_name = ask("Author name?", default: git_meta[:user_name])
  github_repo = ask("GitHub repository?", default: git_meta[:origin_repo_path])
  exe = ask_yes_or_no("Include an executable (CLI) in this gem?", default: "N")

  created_labels = \
    if gh_present?
      puts
      puts "I would like to use the `gh` executable to create labels in your repo."
      puts "These labels will be used to generate nice-looking release notes."
      puts
      if ask_yes_or_no("Create GitHub labels using `gh`?", default: "Y")
        create_labels(github_repo)
        true
      end
    end

  replace_in_file(".github/dependabot.yml", /\s+labels:\n\s+-.*$/ => "") unless created_labels

  git "mv", ".github/workflows/release-drafter.yml.dist", ".github/workflows/release-drafter.yml"

  FileUtils.mkdir_p "lib/#{as_path(gem_name)}"
  FileUtils.mkdir_p "test/#{as_path(gem_name)}"

  ensure_executable "bin/console"
  ensure_executable "bin/setup"

  if exe
    replace_in_file "exe/example",
                    "example" => as_path(gem_name),
                    "Example" => as_module(gem_name)

    git "mv", "exe/example", "exe/#{gem_name}"
    ensure_executable "exe/#{gem_name}"

    replace_in_file "lib/example/cli.rb",
                    "example" => as_path(gem_name),
                    "Example" => as_module(gem_name)

    git "mv", "lib/example/cli.rb", "lib/#{as_path(gem_name)}/cli.rb"
    reindent_module "lib/#{as_path(gem_name)}/cli.rb"

    replace_in_file "lib/example/thor_ext.rb", "Example" => as_module(gem_name)
    git "mv", "lib/example/thor_ext.rb", "lib/#{as_path(gem_name)}/thor_ext.rb"
    reindent_module "lib/#{as_path(gem_name)}/thor_ext.rb"
  else
    git "rm", "exe/example", "lib/example/cli.rb", "lib/example/thor_ext.rb"
    replace_in_file "example.gemspec", 'spec.add_dependency "thor"' => '# spec.add_dependency "thor"'
    remove_line "lib/example.rb", /autoload :ThorExt/
    remove_line "lib/example.rb", /autoload :CLI/
  end

  replace_in_file "LICENSE.txt",
                  "Example Owner" => author_name

  replace_in_file "Rakefile",
                  "example.gemspec" => "#{gem_name}.gemspec",
                  "mattbrictson/gem" => github_repo

  replace_in_file "README.md",
                  "mattbrictson/gem" => github_repo,
                  'require "example"' => %Q(require "#{as_path(gem_name)}"),
                  "example" => gem_name,
                  "replace_with_gem_name" => gem_name,
                  /\A.*<!-- END FRONT MATTER -->\n+/m => ""

  replace_in_file "CHANGELOG.md",
                  "mattbrictson/gem" => github_repo

  replace_in_file "CODE_OF_CONDUCT.md",
                  "owner@example.com" => author_email

  replace_in_file "bin/console",
                  'require "example"' => %Q(require "#{as_path(gem_name)}")

  replace_in_file "example.gemspec",
                  "mattbrictson/gem" => github_repo,
                  '"Example Owner"' => author_name.inspect,
                  '"owner@example.com"' => author_email.inspect,
                  '"example"' => gem_name.inspect,
                  "example/version" => "#{as_path(gem_name)}/version",
                  "Example::VERSION" => "#{as_module(gem_name)}::VERSION",
                  /summary\s*=\s*("")/ => gem_summary.inspect

  git "mv", "example.gemspec", "#{gem_name}.gemspec"

  replace_in_file "lib/example.rb",
                  "example" => as_path(gem_name),
                  "Example" => as_module(gem_name)

  git "mv", "lib/example.rb", "lib/#{as_path(gem_name)}.rb"
  reindent_module "lib/#{as_path(gem_name)}.rb"

  replace_in_file "lib/example/version.rb",
                  "Example" => as_module(gem_name)

  git "mv", "lib/example/version.rb", "lib/#{as_path(gem_name)}/version.rb"
  reindent_module "lib/#{as_path(gem_name)}/version.rb"

  replace_in_file "test/example_test.rb",
                  "Example" => as_module(gem_name)

  git "mv", "test/example_test.rb", "test/#{as_path(gem_name)}_test.rb"

  replace_in_file "test/test_helper.rb",
                  'require "example"' => %Q(require "#{as_path(gem_name)}")

  git "rm", "rename_template.rb"
  Dir.unlink("lib/example") if Dir.empty?("lib/example")

  puts <<~MESSAGE

    All set!

    The project has been renamed from "example" to "#{gem_name}".
    Review the changes and then run:

      git commit && git push

  MESSAGE
end

def assert_git_repo!
  return if File.file?(".git/config")

  warn("This doesn't appear to be a git repo. Can't continue. :(")
  exit(1)
end

def git(*args)
  sh! "git", *args
end

def ensure_executable(path)
  return if File.executable?(path)

  FileUtils.chmod 0o755, path
  git "add", path
end

def sh!(*args)
  puts ">>>> #{args.join(' ')}"
  stdout, status = Open3.capture2(*args)
  raise("Failed to execute: #{args.join(' ')}") unless status.success?

  stdout
end

def remove_line(file, pattern)
  text = File.read(file)
  text = text.lines.filter.grep_v(pattern).join
  File.write(file, text)
  git "add", file
end

def ask(question, default: nil, echo: true)
  prompt = "#{question} "
  prompt << "[#{default}] " unless default.nil?
  print prompt
  answer = if echo
             $stdin.gets.chomp
           else
             $stdin.noecho(&:gets).tap { $stdout.print "\n" }.chomp
           end
  answer.to_s.strip.empty? ? default : answer
end

def ask_yes_or_no(question, default: "N")
  default = default == "Y" ? "Y/n" : "y/N"
  answer = ask(question, default: default)

  answer != "y/N" && answer.match?(/^y/i)
end

def read_git_data
  return {} unless git("remote", "-v").match?(/^origin/)

  origin_url = git("remote", "get-url", "origin").chomp
  origin_repo_path = origin_url[%r{[:/]([^/]+/[^/]+?)(?:\.git)?$}, 1]

  {
    origin_repo_name: origin_repo_path&.split("/")&.last,
    origin_repo_path: origin_repo_path,
    user_email: git("config", "user.email").chomp,
    user_name: git("config", "user.name").chomp
  }
end

def replace_in_file(path, replacements)
  contents = File.read(path)
  replacements.each do |regexp, text|
    contents.gsub!(regexp) do |match|
      next text if Regexp.last_match(1).nil?

      match[regexp, 1] = text
      match
    end
  end

  File.write(path, contents)
  git "add", path
end

def as_path(gem_name)
  gem_name.tr("-", "/")
end

def as_module(gem_name)
  parts = gem_name.split("-")
  parts.map do |part|
    part.gsub(/^[a-z]|_[a-z]/) { |str| str[-1].upcase }
  end.join("::")
end

def reindent_module(path)
  contents = File.read(path)
  namespace_mod = contents[/(?:module|class) (\S+)/, 1]
  return unless namespace_mod.include?("::")

  contents.sub!(namespace_mod, namespace_mod.split("::").last)
  namespace_mod.split("::")[0...-1].reverse_each do |mod|
    contents = "module #{mod}\n#{contents.gsub(/^/, '  ')}end\n"
  end

  File.write(path, contents)
  git "add", path
end

def gh_present?
  system "gh label clone -h > /dev/null 2>&1"
rescue StandardError
  false
end

def create_labels(github_repo)
  system "gh label clone mattbrictson/gem --repo #{github_repo.shellescape}"
end

main if $PROGRAM_NAME == __FILE__
