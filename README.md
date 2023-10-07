# gem template

This is a GitHub template for creating Ruby gems. Press [**Use this template**](https://github.com/mattbrictson/gem/generate) to generate a project from this template. In the generated project, run this script to rename the gem to meet your needs:

```
ruby rename_template.rb
```

Note that to get the full benefits of the script, you will need the [gh](https://github.com/cli/cli) command installed.

This template is based on `bundle gem` with some notable improvements:

- GitHub Actions configuration
- Minitest, with minitest-reporters for nicely formatted test output
- Rubocop with a good set of configuration
- CLI scaffolding, built on top of Thor (optional; for more background, read [Fixing Thor’s CLI Quirks](https://mattbrictson.com/blog/fixing-thor-cli-behavior))
- [release-drafter](https://github.com/apps/release-drafter) GitHub Action for automating release notes
- A `rake bump` task to keep your Ruby and Bundler dependencies up to date
- A nice README with badges ready to go (see below)

---

<!-- END FRONT MATTER -->

# example

[![Gem Version](https://img.shields.io/gem/v/replace_with_gem_name)](https://rubygems.org/gems/replace_with_gem_name)
[![Gem Downloads](https://img.shields.io/gem/dt/replace_with_gem_name)](https://www.ruby-toolbox.com/projects/replace_with_gem_name)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mattbrictson/gem/ci.yml)](https://github.com/mattbrictson/gem/actions/workflows/ci.yml)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/mattbrictson/gem)](https://codeclimate.com/github/mattbrictson/gem)

TODO: Description of this gem goes here.

---

- [Quick start](#quick-start)
- [Support](#support)
- [License](#license)
- [Code of conduct](#code-of-conduct)
- [Contribution guide](#contribution-guide)

## Quick start

```
gem install example
```

```ruby
require "example"
```

## Support

If you want to report a bug, or have ideas, feedback or questions about the gem, [let me know via GitHub issues](https://github.com/mattbrictson/gem/issues/new) and I will do my best to provide a helpful answer. Happy hacking!

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of conduct

Everyone interacting in this project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Contribution guide

Pull requests are welcome!
