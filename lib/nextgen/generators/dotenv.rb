# frozen_string_literal: true

install_gem "dotenv", version: ">= 3.0", group: %i[development test]
copy_file ".env.sample"
gitignore "/.env*", "!/.env.sample"
