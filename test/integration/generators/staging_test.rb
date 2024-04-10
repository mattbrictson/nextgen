require_relative "test_case"

class Nextgen::Generators::StagingTest < Nextgen::Generators::TestCase
  destination File.join(Dir.tmpdir, "test_#{SecureRandom.hex(8)}")
  setup :prepare_destination

  test "creates a config/environments/staging.rb file" do
    apply_generator
    assert_file "config/environments/staging.rb"
  end

  test "adds a :staging section to config/cable.yml,database.yml" do
    FileUtils.mkdir_p(File.join(destination_root, "config"))
    File.write(File.join(destination_root, "config/cable.yml"), <<~CABLE_YML)
      development:
        adapter: redis
        url: redis://localhost:6379/1

      test:
        adapter: test

      production:
        adapter: redis
        url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
        channel_prefix: myapp_production
    CABLE_YML
    File.write(File.join(destination_root, "config/database.yml"), <<~DATABASE_YML)
      # SQLite. Versions 3.8.0 and up are supported.
      #   gem install sqlite3
      #
      #   Ensure the SQLite 3 gem is defined in your Gemfile
      #   gem "sqlite3"
      #
      default: &default
        adapter: sqlite3
        pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
        timeout: 5000

      development:
        <<: *default
        database: storage/development.sqlite3

      # Warning: The database defined as "test" will be erased and
      # re-generated from your development database when you run "rake".
      # Do not set this db to the same as development or production.
      test:
        <<: *default
        database: storage/test.sqlite3

      production:
        <<: *default
        database: storage/production.sqlite3
    DATABASE_YML

    apply_generator

    assert_file "config/cable.yml", /#{Regexp.quote(<<~YML)}/
      staging:
        adapter: redis
        url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
        channel_prefix: myapp_staging
    YML

    assert_file "config/database.yml", /#{Regexp.quote(<<~YML)}/
      staging:
        <<: *default
        database: storage/staging.sqlite3
    YML
  end
end
