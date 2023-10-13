# Examples

The Rails apps in this directory were all generated by `gem exec nextgen create` with various interactive menu items chosen.

## default

[`examples/default`](./default) was created by choosing the default option for every question, and declining all optional Nextgen enhancements. This generally represents the default Rails "omakase" experience with a [base](../lib/nextgen/generators/base.rb) level of improvements.

```
What version of Rails will you use?
‣ 7.1.1
  edge (7-1-stable branch)

Which database?
‣ SQLite3 (default)
  PostgreSQL (recommended)
  MySQL
  More options...

What style of Rails app do you need?
‣ Standard, full-stack Rails (default)
  API only

How will you manage frontend assets?
‣ Sprockets (default)
  Propshaft
  Vite

Which CSS framework will you use with the asset pipeline?
‣ None (default)
  Bootstrap
  Bulma
  PostCSS
  Sass
  Tailwind

Which JavaScript bundler will you use with the asset pipeline?
‣ Importmap (default)
  ESBuild
  Rollup
  Webpack
  None

Which optional Rails frameworks do you need?
‣ ⬢ Hotwire
  ⬢ JBuilder
  ⬢ Action Mailer
  ⬢ Active Job
  ⬢ Action Cable
  ⬢ Active Storage
  ⬢ Action Text
  ⬢ Action Mailbox

Which test framework will you use?
‣ Minitest (default)
  RSpec
  None

Include system testing (capybara)?
‣ Yes (default)
  No

Which optional enhancements would you like to add?
‣ ⬡ Annotate Models
  ⬡ BasicAuth controller concern
  ⬡ Brakeman
  ⬡ Bundler Audit
  ⬡ capybara-lockstep
  ⬡ dotenv-rails
  ⬡ ERB Lint
  ⬡ ESLint
  ⬡ Factory Bot
  ⬡ GitHub Actions
  ⬡ good_migrations
  ⬡ letter_opener
  ⬡ Open browser on startup
  ⬡ Overcommit
  ⬡ rack-canonical-host
  ⬡ rack-mini-profiler
  ⬡ RuboCop
  ⬡ shoulda
  ⬡ Sidekiq
  ⬡ Stylelint
  ⬡ Thor
  ⬡ Tomo
```

## rspec

[`examples/rspec`](./rspec) is the same as the default example, except "RSpec" was chosen when prompted to select a test framework:

```
Which test framework will you use?
  Minitest (default)
‣ RSpec
  None
```

## vite

[`examples/vite`](./vite) shows what is generated when "Vite" is chosen as an alternative to Sprockets.

```
How will you manage frontend assets?
  Sprockets (default)
  Propshaft
‣ Vite
```

## all

[`examples/all`](./all) shows what is generated when all optional Nextgen enhancements are selected, including Sidekiq, Factory Bot, GitHub Actions, RuboCop, and more than a dozen others.

```
Which optional enhancements would you like to add?
‣ ⬢ Annotate Models
  ⬢ BasicAuth controller concern
  ⬢ Brakeman
  ⬢ Bundler Audit
  ⬢ capybara-lockstep
  ⬢ dotenv-rails
  ⬢ ERB Lint
  ⬢ ESLint
  ⬢ Factory Bot
  ⬢ GitHub Actions
  ⬢ good_migrations
  ⬢ letter_opener
  ⬢ Open browser on startup
  ⬢ Overcommit
  ⬢ rack-canonical-host
  ⬢ rack-mini-profiler
  ⬢ RuboCop
  ⬢ shoulda
  ⬢ Sidekiq
  ⬢ Stylelint
  ⬢ Thor
  ⬢ Tomo
```