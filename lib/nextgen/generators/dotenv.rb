# frozen_string_literal: true

# kamal is incompatible with the latest version of dotenv, so fall back
# to using the legacy dotenv-rails gem in that case.
if File.read("Gemfile.lock").match?(/\bkamal\b/)
  install_gem "dotenv-rails", group: %i[development test]
else
  install_gem "dotenv", version: ">= 3.0", group: %i[development test]
end
copy_file ".env.sample"
gitignore "/.env*", "!/.env.sample"
