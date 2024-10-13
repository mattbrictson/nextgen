# all_example

This is a Rails 7.2 app.

## Prerequisites

This project requires:

- Ruby (see [.ruby-version](./.ruby-version)), preferably managed using [rbenv](https://github.com/rbenv/rbenv)
- Node 18 (LTS) or newer
- Yarn 1.x (classic)

On macOS, these [Homebrew](http://brew.sh) packages are recommended:

```
brew install rbenv
brew install node
brew install yarn
```

## Getting started

### bin/setup

Run this script to install necessary dependencies and prepare the Rails app to be started for the first time.

```
bin/setup
```

> [!TIP]
> The `bin/setup` script is idempotent and is designed to be run often. You should run it every time you pull code that introduces new dependencies or makes other significant changes to the project.

### Run the app!

Start the Rails server with this command:

```
bin/dev
```

The app will be located at <http://localhost:3000/>.

## Development

Use this command to run the full suite of automated tests and lint checks:

```
bin/rake
```

> [!TIP]
> Rake allows you to run all checks in parallel with the `-m` option. This is much faster, but since the output is interleaved, it may be harder to read.

```
bin/rake -m
```

### Fixing lint issues

Some lint issues can be auto-corrected. To fix them, run:

```
bin/rake fix
```

> [!WARNING]
> A small number of Rubocop's auto-corrections are considered "unsafe" and may
> occasionally produce incorrect results. After running `fix`, you should
> review the changes and make sure the code still works as intended.
