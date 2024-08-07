# Nextgen

[![Gem Version](https://img.shields.io/gem/v/nextgen)](https://rubygems.org/gems/nextgen)
[![Gem Downloads](https://img.shields.io/gem/dt/nextgen)](https://www.ruby-toolbox.com/projects/nextgen)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mattbrictson/nextgen/ci.yml)](https://github.com/mattbrictson/nextgen/actions/workflows/ci.yml)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/mattbrictson/nextgen)](https://codeclimate.com/github/mattbrictson/nextgen)

Nextgen is an **interactive** and flexible alternative to `rails new` that includes opt-in support for modern frontend development with ⚡️**Vite.**

[**Requirements**](#requirements)
|
[**Usage**](#usage)
|
[**Examples**](./examples)
|
[**What's included**](#whats-included)<br>
[Support](#support)
|
[License](#license)
|
[Code of conduct](#code-of-conduct)
|
[Contribution guide](#contribution-guide)

![Screen recording of Nextgen in action](./demo.gif)

## Requirements

Nextgen generates apps using **Rails 7.2**.

- **Ruby 3.1+** is required
- **Rubygems 3.4.8+** is required (run `gem update --system` to get it)
- **Node 18.12+ and Yarn** are required if you choose Vite or other Node-based options
- Additional tools may be required depending on the options you select (e.g. PostgreSQL)

Going forward, my goal is that Nextgen will always target the latest stable version of Rails and the next pre-release version. Support for Node LTS and Ruby versions will be dropped as soon as they reach EOL (see [Ruby](https://endoflife.date/ruby) and [Node](https://endoflife.date/nodejs) EOL schedules).

## Usage

To create a new Rails app with Nextgen, run:

```
gem exec nextgen create myapp
```

This will download the latest version of the `nextgen` gem and use it to create an app in the `myapp` directory. You'll be asked to configure the tech stack through several interactive prompts. If you have a `~/.railsrc` file, it will be ignored.

> [!TIP]
> If you get an "Unknown command exec" error, fix it by upgrading rubygems: `gem update --system`.

## Examples

Check out the [examples directory](./examples) to see some Rails apps that were generated with `nextgen create`. RSpec, Vite, and vanilla Rails variations are included.

## What's included

**Nextgen starts with the "omakase" default behavior of `rails new`,** so you get the great things included in Rails 7.1 like a production-ready Dockerfile, your choice of database platform, CSS framework, etc. You can also interactively disable parts of the default stack that you don't need, like JBuilder or Action Mailbox.

On top of that foundation, Nextgen offers dozens of useful enhancements to the vanilla Rails experience. You are free to pick and choose which (if any) of these to apply to your new project. Behind the scenes, **each enhancement is applied in a separate git commit,** so that you can later see what was applied and why, and revert the suggestions if necessary.

> [!TIP]
> For the full list of what Nextgen provides, check out [config/generators.yml](https://github.com/mattbrictson/nextgen/tree/main/config/generators.yml). The source code of each generator can be found in [lib/nextgen/generators](https://github.com/mattbrictson/nextgen/tree/main/lib/nextgen/generators).

Here are some highlights of what Nextgen brings to the table:

### GitHub Actions

Nextgen can optionally set up a GitHub Actions CI workflow for your app that automatically runs tests, linters, and security checks based on the gems and packages you have installed.

### Minitest or RSpec

Prefer RSpec? Nextgen can set you up with RSpec, plus the gems and configuration you need for system specs (browser testing). Or stick with the Rails Minitest defaults. In either case, Nextgen will set up a good default Rake task and appropriate CI job.

### Gems

Nextgen can install and configure your choice of these recommended gems:

- [annotate](https://github.com/ctran/annotate_models)
- [brakeman](https://github.com/presidentbeef/brakeman)
- [bundler-audit](https://github.com/rubysec/bundler-audit)
- [capybara-lockstep](https://github.com/makandra/capybara-lockstep)
- [dotenv](https://github.com/bkeepers/dotenv)
- [erb_lint](https://github.com/Shopify/erb-lint)
- [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails)
- [good_migrations](https://github.com/testdouble/good-migrations)
- [letter_opener](https://github.com/ryanb/letter_opener)
- [overcommit](https://github.com/sds/overcommit)
- [pgcli-rails](https://github.com/mattbrictson/pgcli-rails)
- [rack-canonical-host](https://github.com/tylerhunt/rack-canonical-host)
- [rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
- [rubocop](https://github.com/rubocop/rubocop)
- [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers)
- [sidekiq](https://github.com/sidekiq/sidekiq)
- [thor](https://github.com/rails/thor)
- [tomo](https://github.com/mattbrictson/tomo)
- [vcr](https://github.com/vcr/vcr)

### Node packages

Nextgen can optionally install and configure these Node packages to work nicely with Rails:

- [eslint](https://github.com/eslint/eslint)
- [stylelint](https://github.com/stylelint/stylelint)

### Vite

[Vite](https://vitejs.dev) (pronounced _veet_) is a next generation Node-based frontend build system and hot-reloading dev server. It can completely take the place of the asset pipeline and integrate seamlessly with Rails via the [vite_rails](https://github.com/ElMassimo/vite_ruby) gem. If you opt-in, Nextgen can set you up with Vite and adds a bunch of vite_rails best practices:

- All frontend sources (CSS, JS, images) are moved to `app/frontend`
- A `bin/dev` script is used to start the Rails server and Vite dev server
- The [autoprefixer](https://github.com/postcss/autoprefixer) package is installed and activated via PostCSS
- A base set of CSS files are added, including [modern_normalize](https://github.com/sindresorhus/modern-normalize)
- A Vite-compatible inline SVG helper is added
- The [stimulus-vite-helpers](https://github.com/ElMassimo/stimulus-vite-helpers) package is installed (if Stimulus is detected)
- `vite-plugin-ruby` is replaced with the more full-featured `vite-plugin-rails`
- Sprockets is removed and the asset pipeline is disabled
- Vite's `autoBuild` is turned off for the test environment

These recommendations are based on my experience using Vite with Rails in multiple production apps. For additional background on these and other Vite-related changes, check out the following blog posts:

- [How to organize CSS in a Rails project](https://mattbrictson.com/blog/organizing-css-in-rails)
- [Fixing slow, flaky system tests in Vite-Rails](https://mattbrictson.com/blog/faster-vite-test-without-autobuild)
- [The 3 Vite plugins I use on every new Rails project](https://mattbrictson.com/blog/3-vite-rails-plugins)
- [Inline SVGs with Rails and Vite](https://mattbrictson.com/blog/inline-svg-with-vite-rails)

## Support

If you want to report a bug, or have ideas, feedback or questions about Nextgen, [let me know via GitHub issues](https://github.com/mattbrictson/nextgen/issues/new) and I will do my best to provide a helpful answer. Happy hacking!

## License

Nextgen is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of conduct

Everyone interacting in this project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Contribution guide

Pull requests are welcome!
