# default_example

This is a Rails 7.1 app.

## Prerequisites

This project requires:

- Ruby (see [.ruby-version](./.ruby-version)), preferably managed using [rbenv](https://github.com/rbenv/rbenv)

On macOS, these [Homebrew](http://brew.sh) packages are recommended:

```
brew install rbenv
```

## Getting started

### bin/setup

Run this script to install necessary dependencies and prepare the Rails app to be started for the first time.

```
bin/setup
```

> [!NOTE]
> The `bin/setup` script is idempotent and is designed to be run often. You should run it every time you pull code that introduces new dependencies or makes other significant changes to the project.

### Run the app!

Start the Rails server with this command:

```
bin/rails s
```

The app will be located at <http://localhost:3000/>.

## Development

Use this command to run the full suite of automated tests:

```
bin/rake
```
