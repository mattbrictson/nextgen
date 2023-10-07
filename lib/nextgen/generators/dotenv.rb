install_gem "dotenv-rails", group: %i[development test]
copy_file ".env.sample"
gitignore "/.env*", "!/.env.sample"
